class Attribute < ApplicationRecord
  def self.api_id(api)
    self.find_by!(api: api).id
  end

  def self.api_dataset(api)
    self.find_by!(api: api).dataset
  end

  def self.api_datamodel(api)
    self.find_by!(api: api).datamodel
  end
end
