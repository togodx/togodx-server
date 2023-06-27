class Classification < ApplicationRecord
  acts_as_nested_set counter_cache: :count

  module Base
    extend ActiveSupport::Concern

    include Breakdown

    module ClassMethods
      # @return [Array<String>] list of classification (leaves' ID)
      def entries(node = nil)
        find_by!(classification: node.presence || root.classification).entries
      end

      # @return [Array<Hash>, Hash]
      def breakdown(node, mode = 'numerical_desc', **options)
        classification = find_by!(classification: node.presence || root.classification)

        children = classification.child_nodes
                                 .map { |child| child.breakdown }

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
        classification = find_by!(classification: node.presence || root.classification)

        count_total = where(leaf: true).distinct.count(:classification)
        count_queries = where(leaf: true).where(classification: queries).distinct.count(:classification)

        children = classification.child_nodes
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

      def suggest(term)
        op = case ActiveRecord::Base.connection_db_config.adapter
             when 'postgresql'
               'ILIKE'
             else
               'LIKE'
             end

        result = where(leaf: false)
                   .where(%Q["#{table_name}"."classification_label" #{op} ?], "%#{term}%")
                   .where(classification_origin: nil)
                   .order(%Q[LOWER("#{table_name}"."classification_label")])

        {
          results: result.map { |x| { node: x.classification, label: x.classification_label } },
          total: result.size
        }
      end

      def is_hierarchy
        parent_id = select(:id).where(parent_id: select(:id).where(parent_id: nil))
        where(leaf: false).where(parent_id:).count.positive?
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
      base = classification_origin || classification

      self.class
          .where(classification: base)
          .or(self.class.where(classification_origin: base))
          .map(&:parent)
          .reject(&:classification_origin)
    end

    # @return [ActiveRecord::Relation<Classification>]
    def child_nodes
      children.where(leaf: false)
    end

    # @return [ActiveRecord::Relation<Classification>]
    def descendant_leaves
      descendants.where(leaf: true)
    end

    def tip?
      children.all?(&:leaf)
    end
  end
end
