class Distribution < ApplicationRecord
  module Base
    extend ActiveSupport::Concern

    include Breakdown

    module ClassMethods
      # @return [Array<Hash>]
      def breakdown(_node = nil, mode = nil, **options)
        mode ||= 'id_asc'
        sort_breakdown(histogram, mode).map { |hash| hash.merge(node: hash[:node].to_s) }
      end

      # @return [Array<Hash>]
      def histogram
        group(:bin_id, :bin_label).count.map do |k, v|
          {
            node: k[0].to_i,
            label: k[1],
            count: v,
          }
        end
      end

      # @param [NilClass,String] node A string representing a range. (e.g. "10-20")
      # @return [Array<String>] list of distribution
      def entries(node = nil)
        (node ? where(bin_id: node) : all).map(&:distribution)
      end

      def labels(nodes, conditions)
        where(distribution: nodes, bin_id: conditions).map do |leaf|
          {
            id: leaf.distribution,
            node: leaf.bin_id,
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
              node: x.bin_id,
              label: x.bin_label,
              count: x.count_subtotal,
              mapped: x.count_hits,
              pvalue: Stat.pvalue(count_total, x.count_subtotal, count_queries, x.count_hits)
            }
          end
      end

      def default_categories
        distinct(:bin_id).order(:bin_id).pluck(:bin_id)
      end

      def sub_categories
        default_categories
      end

      def find_labels(queries)
        select('"distribution" AS "identifier", "distribution_label" AS "label"')
          .where(distribution: queries)
          .distinct
      end

      def suggest(_term)
        []
      end
    end
  end
end
