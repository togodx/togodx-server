module Stat
  # Ported from https://integbio.jp/togosite/sparqlist/map_ids_to_attribute
  # with 2.2 EASE Score, a Modified Fisher Exact P-value described in
  # https://david.ncifcrf.gov/content.jsp?file=functional_annotation.html
  def pvalue(total, subtotal, queries, hits)
    # originalDistribution[i].hit_count - 1
    a = hits - 1
    # queries - originalDistribution[i].hit_count
    b = queries - hits
    # originalDistribution[i].count - (originalDistribution[i].hit_count - 1)
    c = subtotal - hits + 1
    # population - originalDistribution[i].count - queries
    d = total - subtotal - queries - hits

    return if hits == 0
    return 1 if hits == 1
    # if (a < 0 || b < 0 || c < 0 || d < 0) return false;
    return if [a, b, c, d].any?(&:negative?)
    # if (a > maxLimit || b > maxLimit || c > maxLimit || d > maxLimit) return false;
    max_limit = 300000
    return if [a, b, c, d].any? { |v| v > max_limit }

    # https://github.com/phillbaker/rubystats/blob/master/lib/rubystats/fishers_exact_test.rb
    Rubystats::FishersExactTest.new.calculate(a, b, c, d)[:twotail]
  end

  module_function :pvalue
end
