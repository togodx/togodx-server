class Classification < ApplicationRecord
  acts_as_nested_set counter_cache: :count

  module Base
    extend ActiveSupport::Concern

    include Breakdown

    module ClassMethods
      # @return [Array<String>] list of classification (leaves' ID)
      def entries(node = nil)
        find_by!(classification: node || root).classification.entries
      end

      # @return [Array<Hash>, Hash]
      def breakdown(node, mode = 'numerical_desc', **options)
        classification = find_by!(classification: node || root)

        children = classification.child_nodes_excluding_no_leaves
                                 .map { |child| child.breakdown }
                                 .reject { |x| x[:count].zero? }

        children = sort_breakdown(children, mode)

        if options[:hierarchy]
          {
            self: classification.breakdown,
            parents: classification.root? ? nil : sort_breakdown(classification.parents.map(&:breakdown), mode),
            children:
          }
        else
          children
        end
      end

      # @return [Array<Hash>, Hash]
      def locate(queries, node = nil, **options)
        puts "options: #{options}"
        classification = find_by!(classification: node || root)

        count_total = where(leaf: true).distinct.count(:classification)
        count_queries = where(leaf: true).where(classification: queries).distinct.count(:classification)

        children = classification.child_nodes_excluding_no_leaves
                                 .map { |child| child.locate(queries, count_total, count_queries) }

        if options[:hierarchy]
          {
            self: classification.locate(queries, count_total, count_queries),
            parents: classification.root? ? nil : classification.parents.map { |x| x.locate(queries, count_total, count_queries) },
            children:
          }
        else
          children
        end
      end

      # @param [Object] nodes Identifiers
      # @param [Object] conditions Selected nodes
      def labels(nodes, conditions)
        nodes = where(classification: conditions).map { |node| [node, node.descendants.where(leaf: true, classification: nodes)] }

        nodes.map do |node, leaves|
          leaves.pluck(:classification).uniq.map do |classification|
            {
              id: classification,
              node: node.classification,
              label: node.classification_label
            }
          end
        end.flatten
      end

      # TODO: frontend should pass default categories
      def default_categories
        sub_categories(root.classification)
      end

      def sub_categories(node)
        find_by(classification: node)&.children&.where(leaf: false)&.map(&:classification) || []
      end

      def built?
        where.not(parent_id: nil).count.positive?
      end

      def find_labels(queries)
        select('"classification" AS "identifier", "classification_label" AS "label"')
          .where(classification: queries)
          .distinct
      end

      SUGGEST_RESULT_MAX = 10

      def suggest(term)
        op = case ActiveRecord::Base.connection_db_config.adapter
             when 'postgresql'
               'ILIKE'
             else
               'LIKE'
             end

        result = where(%Q["#{table_name}"."classification_label" #{op} ?], "%#{term}%")
                   .order(%Q[LOWER("#{table_name}"."classification_label")])
                   .reject { |x| x.classification.match?(/-\d+$/) } # TODO: update the DAG determination method

        {
          results: result.take(SUGGEST_RESULT_MAX).map { |x| { node: x.classification, label: x.classification_label } },
          total: result.size
        }
      end
    end

    # @return [Array<String>] list of classification (leaves' ID)
    def entries
      descendant_leaves.pluck(:classification)
    end

    # @return [Hash]
    def breakdown
      {
        node: classification,
        label: classification_label,
        count: descendant_leaves.distinct.count(:classification),
        tip: tip?
      }
    end

    # @return [Hash]
    def locate(queries, count_total, count_queries)
      leaves = descendant_leaves.distinct.unscope(:order).pluck(:classification)
      count_subtotal = leaves.count
      count_hits = (queries & leaves).count

      {
        node: classification,
        label: classification_label,
        count: count_subtotal,
        mapped: count_hits,
        pvalue: Stat.pvalue(count_total, count_subtotal, count_queries, count_hits)
      }
    end

    def parents
      # TODO: update the DAG determination method
      base = classification.match?(/-\d+$/) ? classification.match(/(.*)-\d+$/).captures.first : classification

      nodes = [self].concat(self.class.where(%Q["#{self.class.table_name}"."classification" LIKE ?], "#{base}-%"))
      # nodes = [self] # TODO: simplify if the attribute is non-dag tree for better performance

      nodes.map(&:parent).reject { |x| x.classification.match(/(.*)-\d+$/) }
    end

    # @return [ActiveRecord::Relation<Classification>]
    def children_without_leaf
      children.where(leaf: false)
    end

    # @return [ActiveRecord::Relation<Classification>]
    def descendant_leaves
      descendants.where(leaf: true)
    end

    def children_excluding_no_leaves
      children.reject { |x| !x.leaf && x.descendant_leaves.count(:classification).zero? }
    end

    def child_nodes_excluding_no_leaves
      children_without_leaf.reject { |x| !x.leaf && x.descendant_leaves.count(:classification).zero? }
    end

    def tip?
      children_excluding_no_leaves.all?(&:leaf)
    end
  end
end
