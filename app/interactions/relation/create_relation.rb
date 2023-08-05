# frozen_string_literal: true

class Relation
  class CreateRelation < ApplicationInteraction
    string :source
    string :target

    def execute
      pair = [source, target].sort

      [
        Relation.find_or_create_by!(source: pair[0], target: pair[1]),
        Relation.find_or_create_by!(source: pair[1], target: pair[0])
      ]
    end
  end
end
