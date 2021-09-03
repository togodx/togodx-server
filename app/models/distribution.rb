class Distribution < ApplicationRecord
  include Breakdown

  # TODO: fetch from attributes.json for each attribute in the future
  def binopts
    {
      :size   => 10000,
      :digits => 0,
      :scale  => 0.001,
      :spacer => "-",
      :unit   => "kDa",
      :min    => 0,
      :max    => 200000,
    }
  end

  def breakdown(node = nil, mode = nil)
    list = bin_split(binopts)
    sort_breakdown(list, mode)
  end

  private

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

  def count_breakdown(label, min, max = Float::INFINITY)
    # self: instance (table#)
    # self.class: Distribution
    count = self.class.where(distribution_value: min...max).count
    { label: label, count: count }
  end
end
