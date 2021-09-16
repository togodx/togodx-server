class Distribution < ApplicationRecord
  module Base
    extend ActiveSupport::Concern

    include Breakdown
    include Pvalue

    module ClassMethods
      # @return [Array<Hash>]
      def breakdown(_node = nil, mode = nil)
        sort_breakdown(histogram, mode)
      end

      # @return [Array<Hash>]
      def histogram
        group(:bin_id, :bin_label).count.map do |k, v|
          {
            label: k[1],
            count: v,
            categoryId: k[0].to_i,
            hasChild: false     # not used
          }
        end
      end

      # @param [NilClass,String] node A string representing a range. (e.g. "10-20")
      # @return [Array<String>] list of distribution
      def entries(node = nil)
        (node ? where(bin_id: node) : all).map(&:distribution)
      end

      def labels(node, _conditions)
        where(distribution: node).map do |leaf|
          {
            categoryId: node,
            uri: 'TODO: FIXME',
            label: leaf.bin_label
          }
        end
      end

      def locate(queries, node = nil)
        count_total = count
        count_queries = where(distribution: queries).count

        hits = select('COUNT(*)')
                 .where(%Q["#{table_name}"."bin_id" = "t1"."bin_id"])
                 .where(distribution: queries)
                 .to_sql

        select('"t1"."bin_id"', '"t1"."bin_label"', 'COUNT(*) AS count_subtotal', "(#{hits}) AS count_hits")
          .from(%Q["#{table_name}" AS "t1"])
          .group('"t1"."bin_id"', '"t1"."bin_label"')
          .map do |x|
            {
              categoryId: x.bin_id,
              label: x.bin_label,
              count: x.count_subtotal,
              hit_count: x.count_hits,
              pValue: pvalue(count_total, x.count_subtotal, count_queries, x.count_hits)
            }
          end
      end

      def default_categories
        all.map(&:distribution)
      end
    end
  end
end
