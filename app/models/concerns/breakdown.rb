module Breakdown
  extend ActiveSupport::Concern

  module ClassMethods
    def sort_breakdown(list, mode)
      comparator = comparator(mode)
      list.sort { |a, b| a[:categoryId] == 'unclassified' ? 1 : comparator.call(a, b) }
    end

    def count_breakdown
      raise NotImplementedError
    end

    private

    def comparator(mode)
      case mode
      when 'id_asc', nil # defalut
        ->(a, b) { a[:categoryId] <=> b[:categoryId] }
      when 'id_desc'
        ->(a, b) { b[:categoryId] <=> a[:categoryId] }
      when 'numerical_asc'
        ->(a, b) { a[:count] <=> b[:count] }
      when 'numerical_desc'
        ->(a, b) { b[:count] <=> a[:count] }
      when 'alphabetical_asc'
        ->(a, b) { a[:label] <=> b[:label] }
      when 'alphabetical_desc'
        ->(a, b) { b[:label] <=> a[:label] }
      else
        raise ArgumentError, "Mode #{mode} is not acceptable. Available modes are numerical_asc, numerical_desc, alphabetical_asc, or alphabetical_desc"
      end
    end
  end

  def count_breakdown
    raise NotImplementedError
  end
end
