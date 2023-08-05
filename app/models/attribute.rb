class Attribute < ApplicationRecord
  module DataModel
    CLASSIFICATION = 'classification'
    DISTRIBUTION = 'distribution'
  end

  class << self
    # @return [ActiveRecord::Relation<Attribute>]
    def classifications
      where(datamodel: DataModel::CLASSIFICATION)
    end

    # @return [ActiveRecord::Relation<Attribute>]
    def distributions
      where(datamodel: DataModel::DISTRIBUTION)
    end

    # @param [String] dataset
    # @return [ActiveRecord::Relation<Attribute>]
    def datasets(dataset)
      where(dataset: dataset)
    end

    # @param [String] key
    # @return [Attribute]
    def from_key(key)
      return @from_key[key] if (@from_key ||= {})[key].present?

      @from_key[key] ||= find_by!(key: key)
    rescue
      raise ApplicationRecord::AttributeNotFound, "'#{key}' not found"
    end
  end

  def to_model_class
    case datamodel.downcase
    when DataModel::CLASSIFICATION
      Classification
    when DataModel::DISTRIBUTION
      Distribution
    else
      raise NameError, "Invalid data model: #{datamodel}"
    end
  end

  # @return [TrueClass, FalseClass]
  def classification?
    datamodel == DataModel::CLASSIFICATION
  end

  # @return [TrueClass, FalseClass]
  def distribution?
    datamodel == DataModel::DISTRIBUTION
  end

  # @return [Class] corresponding ActiveRecord class, subclass of `Classification` or `Distribution`.
  def table
    Object.const_get("Table#{id}")
  rescue
    klass = eval <<~RUBY
      class Table#{id} < ApplicationRecord
        self.table_name = "table#{id}"
        include #{to_model_class.name}::Base
      end
    RUBY

    Object.const_set("Table#{id}", klass)

    retry
  end
end
