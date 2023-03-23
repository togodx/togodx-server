class Classification < ApplicationRecord
  acts_as_nested_set counter_cache: :count

  module Base
    extend ActiveSupport::Concern

    include Breakdown

    module ClassMethods
      # @return [Array<Hash>, Hash]
      def breakdown(node = nil, mode = nil, **options)
        classification = node ? find_by(classification: node) : root
        children = classification&.breakdown(mode) || []

        if options[:hierarchy]
          {
            self: classification&.count_breakdown,
            parents: classification&.root? ? nil : classification&.parents,
            children:
          }
        else
          children
        end
      end

      # @return [Array<String>] list of classification (leaves' ID)
      def entries(node = nil)
        (node ? find_by(classification: node) : root)&.entries || []
      end

      # @param [Object] nodes Identifiers
      # @param [Object] conditions Selected nodes
      def labels(nodes, conditions)
        where(classification: conditions).map { |node| [node, node.descendants.where(leaf: true, classification: nodes)] }
                                         .map do |node, leaves|
          leaves.pluck(:classification).uniq.map do |classification|
            {
              id: classification,
              node: node.classification,
              label: node.classification_label
            }
          end
        end.flatten
      end

      def locate(queries, node = nil)
        (node ? find_by(classification: node) : root)&.locate(queries) || []
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
    end

    # @return [Array<Hash>]
    def breakdown(mode = nil)
      list = children_without_leaf
               .map { |child| child.count_breakdown }
               .reject { |x| x[:count].zero? }

      mode ||= 'numerical_desc'
      self.class.sort_breakdown(list, mode)
    end

    # @return [ActiveRecord::Relation<Classification>]
    def children_without_leaf
      self.children.where(leaf: false)
    end

    # @return [Hash]
    def count_breakdown
      {
        node: classification,
        label: classification_label,
        count: (count = descendants.where(leaf: true).distinct.count(:classification)),
        tip: (children_without_leaf.count.zero? || count.zero?)
      }
    end

    # @return [Array<String>] list of classification (leaves' ID)
    def entries
      descendants
        .where(leaf: true)
        .map(&:classification)
    end

    def locate(queries)
      leaves = self.class.where(leaf: true)

      count_total = leaves.distinct.count(:classification)
      count_queries = leaves.where(classification: queries).distinct.count(:classification)

      children_without_leaf.map do |child|
        leaves = child.descendants.where(leaf: true).distinct.unscope(:order).pluck(:classification)
        count_subtotal = leaves.count
        count_hits = (queries & leaves).count

        {
          node: child.classification,
          label: child.classification_label,
          count: count_subtotal,
          mapped: count_hits,
          pvalue: Stat.pvalue(count_total, count_subtotal, count_queries, count_hits)
        }
      end
    end

    def parents
      base = classification.match?(/-\d+$/) ? classification.match(/(.*)-\d+$/).captures.first : classification

      nodes = [self].concat(self.class.where(%Q["#{self.class.table_name}"."classification" LIKE ?], "#{base}-%"))
      # nodes = [self] # TODO: simplify if the attribute is non-dag tree for better performance

      nodes.map(&:parent)
           .map(&:count_breakdown)
    end
  end
end
