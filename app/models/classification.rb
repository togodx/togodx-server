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
        where(classification: node).map { |x| x.ancestors.find_by(classification: conditions) }.compact.map do |x|
          {
            categoryId: x.classification,
            uri: "TODO: FIXME",
            label: x.classification_label
          }
        end
      end

      def locate(queries, node = nil)
        (node ? find_by(classification: node) : root)&.locate(queries) || []
      end
    end

    # @return [Array<Hash>]
    def breakdown(mode = nil)
      list = children_without_leaf.map do |child|
        child.count_breakdown
      end

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
      {
        label: classification_label,
        count: descendants.where(leaf: true).count,
        categoryId: classification,
        hasChild: !children_without_leaf.count.zero?
      }
    end

    # @return [Array<String>] list of classification (leaves' ID)
    def entries
      descendants
        .where(leaf: true)
        .map(&:classification)
    end
  end

  def locate(queries)
    count_total = self.class.where(leaf: true).count
    count_queries = queries.count
    children_without_leaf.map do |child|
      leaves = child.descendants.where(leaf: true).map(&:classification)
      count_subtotal = leaves.count
      count_hits = (queries & leaves).count
      {
        categoryId: child.classification,
        label: child.classification_label,
        count: count_subtotal,
        hit_count: count_hits,
        pValue: pvalue(count_total, count_subtotal, count_queries, count_hits)
      }
    end
  end
end
