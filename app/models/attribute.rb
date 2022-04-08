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

    # @param [String] api
    # @return [Attribute]
    def from_api(api)
      return @from_api[api] if (@from_api ||= {})[api].present?

      @from_api[api] ||= find_by!(api: api)
    rescue
      raise ApplicationRecord::AttributeNotFound, "'#{api}' not found"
    end
  end

  def to_model_class
    case self.datamodel.downcase
    when DataModel::CLASSIFICATION
      Classification
    when DataModel::DISTRIBUTION
      Distribution
    else
      raise NameError, "Invalid data model: #{attribute.datamodel}"
    end
  end

  # @return [TrueClass, FalseClass]
  def classification?
    self.datamodel == DataModel::CLASSIFICATION
  end

  # @return [TrueClass, FalseClass]
  def distribution?
    self.datamodel == DataModel::DISTRIBUTION
  end

  # @return [Class] corresponding ActiveRecord class, subclass of `Classification` or `Distribution`.
  def table
    Object.const_get("Table#{id}")
  end
end
