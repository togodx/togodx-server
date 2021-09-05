class Distribution < ApplicationRecord
  self.abstract_class = true

  include Breakdown

  class << self
    # # TODO: fetch from attributes.json for each attribute in the future
    def binopts
      {
        size: 10000,
        digits: 0,
        scale: 0.001,
        spacer: '-',
        unit: 'kDa',
        min: 0,
        max: 200000
      }
    end

    # @return [Array<Hash>]
    def breakdown(_node = nil, mode = nil)
      list = bin_split(binopts)
      sort_breakdown(list, mode)
    end

    # @return [Array<Hash>]
    def bin_split(bin)
      0.upto((bin[:max] - bin[:min]) / bin[:size] + 1).map do |i|
        lower_value = bin[:min] + bin[:size] * i
        upper_value = lower_value + bin[:size]
        lower_label = format("%.#{bin[:digits]}f", lower_value * bin[:scale])
        upper_label = format("%.#{bin[:digits]}f", upper_value * bin[:scale])
        if upper_value < bin[:max]
          label = "#{lower_label}#{bin[:spacer]}#{upper_label} #{bin[:unit]}"
        else
          upper_value = nil
          label = "#{upper_label}#{bin[:spacer]} #{bin[:unit]}"
        end
        count_breakdown(label, lower_value, upper_value)
      end
    end

    # @return [Hash]
    def count_breakdown(label, min, max = Float::INFINITY)
      {
        label: label,
        count: where(distribution_value: min...max).count,
        categoryId: label.sub(/\s.*/, ''),
        hasChild: true
      }
    end

    # @param [NilClass,String] node A string representing a range. (e.g. "10-20")
    # @return [Array<String>] list of distribution
    def entries(node = nil)
      from, to = node&.split('-')&.map(&:to_i)
      # TODO: units are needed to calculate distribution_value
      (node ? where(distribution_value: (from * 1_000)..(to * 1_000)) : all)
        .map(&:distribution)
    end
  end
end
