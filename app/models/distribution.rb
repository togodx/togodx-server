class Distribution < ApplicationRecord
  include Breakdown

  class << self
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
          categoryId: k[0],
          hasChild: true
        }
      end
    end

    # @param [NilClass,String] node A string representing a range. (e.g. "10-20")
    # @return [Array<String>] list of distribution
    def entries(node = nil)
      (node ? where(bin_label: node) : all).map(&:distribution)
    end
  end
end
