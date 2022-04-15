class Relation < ApplicationRecord
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      # @param [Array<String>] entries
      # @param [Hash] options
      # @return [Hash]
      def convert(entries, **options)
        pairs(entries, **options)
          .group_by { |x| x[0] }
          .map { |k, v| [k, v.map { |x| x[1] }] }
          .to_h
      end

      # @param [Array<String>] entries
      # @param [Hash] options
      # @return [Array<Array<String>>]
      def pairs(entries, **options)
        if options[:reverse]
          where(target: entries).pluck(:target, :source)
        else
          where(source: entries).pluck(:source, :target)
        end
      end
    end
  end

  class << self
    def from_pair(source, target)
      key = [source, target].join('-')
      return @from_pair[key] if (@from_pair ||= {}).key?(key)

      @from_pair[key] ||= find_by!(source: source, target: target)
    rescue
      raise ApplicationRecord::RelationNotFound, "'#{source}' and '#{target}' not found"
    end

    def datasets
      Attribute.distinct.pluck(:dataset).permutation(2).filter { |src, dst| src < dst }
    end
  end

  def table
    Object.const_get("Relation#{id}")
  end
end
