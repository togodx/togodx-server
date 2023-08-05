# frozen_string_literal: true

class Attribute
  class CreateAttribute < ApplicationInteraction
    string :key
    string :dataset
    string :datamodel
    boolean :hierarchy, default: nil

    def execute
      (attr = Attribute.find_by(key:)) and return attr

      Attribute.create!(key:, dataset:, datamodel:, hierarchy:)
    end
  end
end
