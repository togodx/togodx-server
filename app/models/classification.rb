class Classification < ApplicationRecord
  acts_as_nested_set counter_cache: :count

  module Base
    extend ActiveSupport::Concern

    include Breakdown

    module ClassMethods
      # @return [Array<Hash>]
      def breakdown(node = nil, mode = nil)
        (node ? find_by(classification: node) : root)&.breakdown(mode) || []
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
      count = descendants.where(leaf: true).distinct.count(:classification)
      {
        node: classification,
        label: classification_label,
        count: count,
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
  end
end
