module Breakdown
  extend ActiveSupport::Concern

  module ClassMethods
    def select_table(table_id)
      table = self.clone.tap do |model|
        model.table_name = "table#{table_id}"
      end
      table.new
    end
  end

  private

  def count_breakdown
    raise NotImplementedError
  end

  def sort_breakdown(list, mode)
    case mode
    when "numerical_asc"
      list.sort { |a, b| a[:count] <=> b[:count] }
    when "numerical_desc"
      list.sort { |a, b| a[:count] <=> b[:count] }.reverse
    when "alphabetical_asc", nil  # defalut
      list.sort { |a, b| a[:label] <=> b[:label] }
    when "alphabetical_desc"
      list.sort { |a, b| a[:label] <=> b[:label] }.reverse
    else
      raise(ArgumentError, "Mode #{mode} is not acceptable. Available modes are numerical_asc, numerical_desc, alphabetical_asc, or alphabetical_desc")
    end
  end
end
