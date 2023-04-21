class SuggestTerm < ApplicationInteraction
  string :attribute
  string :term

  validates :term, length: { minimum: 3 }

  def execute
    attr = Attribute.from_key(attribute)
    attr.table.suggest(term)
  end
end
