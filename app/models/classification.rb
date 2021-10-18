class Classification < ApplicationRecord
  acts_as_nested_set counter_cache: :count

  module Base
    extend ActiveSupport::Concern

    include Breakdown
    include Pvalue

    module ClassMethods
      # @return [Array<Hash>]
      def breakdown(node = nil, mode = nil)
        (node ? find_by(classification: node) : root)&.breakdown(mode) || []
      end

      # @return [Array<String>] list of classification (leaves' ID)
      def entries(node = nil)
        (node ? find_by(classification: node) : root)&.entries || []
      end

      def labels(node, conditions)
        where(classification: conditions).map { |x| [x, x.descendants.where(leaf: true).find_by(classification: node)] }
                                         .reject { |_x, y| y.nil?  }
                                         .map do |x, y|
          {
            categoryId: y.classification,
            uri: "TODO: FIXME",
            label: x.classification_label
          }
        end
      end

      def locate(queries, node = nil)
        (node ? find_by(classification: node) : root)&.locate(queries) || []
      end

      # TODO: frontend should pass default categories
      def default_categories
        sub_categories(root.children.classification)
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
      # * renamed categoryId to node (or classificaiton, too long though)
      # * renamed hasChild to tip as an inverse boolean
      count = descendants.where(leaf: true).distinct.count(:classification)
      {
        label: classification_label,
        count: count,
        categoryId: classification,
        hasChild: children_without_leaf.count.positive? && count.positive?
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
          categoryId: child.classification,
          label: child.classification_label,
          count: count_subtotal,
          hit_count: count_hits,
          pValue: self.class.pvalue(count_total, count_subtotal, count_queries, count_hits)
        }
      end
    end
  end
end
