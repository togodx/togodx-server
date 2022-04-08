class Relation < ApplicationRecord

  module Base
    extend ActiveSupport::Concern

    module ClassMethods

      # @param [String] source
      # @param [String] target
      # @param [Array<String>] entries
      # @param [Hash] options
      # @return [Hash]
      def convert(source, target, entries, **options)
        pairs(source, target, entries, **options)
          .group_by { |x| x[0] }
          .map { |k, v| [k, v.map { |x| x[1] }] }
          .to_h
      end

      # @param [String] source
      # @param [String] target
      # @param [Array<String>] entries
      # @param [Hash] options
      # @return [Array<Array<String>>]
      def pairs(source, target, entries, **options)
        flag = source < target ? 1 : -1
        flag *= options[:reverse] ? -1 : 1
        if flag == -1
          where(entry2: entries)
            .pluck(:entry2, :entry1)
        else
          where(entry1: entries)
            .pluck(:entry1, :entry2)
        end
      end
    end
  end

  class << self
    def from_pair(source, target)
      pair = source < target ? "#{source}-#{target}" : "#{target}-#{source}"
      return @from_pair[pair] if (@from_pair ||= {})[pair].present?

      @from_pair[pair] ||= find_by!(pair: pair)
    end
  end

  def table
    Object.const_get("Relation#{id}")
  end
end
