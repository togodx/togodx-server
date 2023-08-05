# frozen_string_literal: true

class Attribute
  class EntryPoint < ApplicationInteraction
    string :key
    string :dataset
    string :datamodel
    boolean :ontology, default: nil
    hash :import do
      string :url
      string :method, default: 'get'
      hash :headers, default: {}, strip: false
      string :body, default: nil
      string :data_type, default: 'auto'
    end

    hash :metadata, default: {}, strip: false
    boolean :debug, default: false

    def execute
      logger.info(self.class) { "Start importing #{key}" }
      logger.debug(self.class) { "Executed with #{inputs.inspect}" } if debug

      compose CreateAttribute, inputs
      table = compose CreateTable, inputs
      if table.present?
        file = compose FetchData, inputs
        compose LoadData, inputs.merge(file:, table:)
      end
    end
  end
end
