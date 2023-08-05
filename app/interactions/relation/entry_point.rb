# frozen_string_literal: true

class Relation
  class EntryPoint < ApplicationInteraction
    string :source
    string :target
    object :file, class: Pathname, converter: :new
    boolean :debug, default: true

    def execute
      logger.info(self.class) { "Start importing relation from #{source} to #{target}" }
      logger.debug(self.class) { "Executed with #{inputs.inspect}" } if debug

      compose(CreateRelation, source:, target:)

      compose(LoadData, source:, target:, file:) if compose(CreateTable, source:, target:)
    end
  end
end
