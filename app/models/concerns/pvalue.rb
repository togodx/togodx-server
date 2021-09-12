module Pvalue
  extend ActiveSupport::Concern

  module ClassMethods
    def pvalue(total, subtotal, queries, hits)
      # originalDistribution[i].hit_count - 1
      a = hits - 1
      # queries - (originalDistribution[i].hit_count - 1)
      b = queries - (hits - 1)
      # originalDistribution[i].count - (originalDistribution[i].hit_count - 1)
      c = subtotal - (hits - 1)
      # population - originalDistribution[i].count - queries
      d = total - subtotal - queries

      return if hits == 0
      return 1 if hits == 1
      # if (a < 0 || b < 0 || c < 0 || d < 0) return false;
      return if [a, b, c, d].any?(&:negative?)
      # if (a > maxLimit || b > maxLimit || c > maxLimit || d > maxLimit) return false;
      max_limit = 300000
      return if [a, b, c, d].any? {|v| v > max_limit}

      # https://github.com/phillbaker/rubystats/blob/master/lib/rubystats/fishers_exact_test.rb
      Rubystats::FishersExactTest.new.calculate(a, b, c, d)[:twotail]
    end
  end
end
