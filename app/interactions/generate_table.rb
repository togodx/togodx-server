class GenerateTable < ApplicationInteraction
  string :target
  array :queries do
    string
  end
  array :filters do
    hash do
      string :propertyId
      array :categoryIds, default: nil do
        string
      end
    end
  end

  def execute
    default_categories = {}
    entry_cache = filters.map { |x| Attribute.from_api(x[:propertyId]).dataset }.uniq.grep_v(target).map do |key|
      [key, Relation.where(db1: key, db2: target, entry2: queries).pluck(:entry2, :entry1).group_by { |x| x[0] }.map { |k, v| [k, v.map { |x| x[1] }] }.to_h]
    end.to_h

    labels = find_labels(target, queries)

    queries.map do |query|
      cols = filters.map do |hash|
        api = hash[:propertyId]

        attribute = Attribute.from_api(api)
        table = attribute.table
        source = attribute.dataset

        conditions = hash[:categoryIds] || (default_categories[api] ||= table.default_categories)

        # primary (target) ID may corresponds to multiple (source) IDs
        entries = if source != target
                    entry_cache[source][query] || []
                  else
                    [query]
                  end

        cells = entries.flat_map do |entry|
          # json.properties.attributes (usually one but map for safe)
          table.labels(entry, conditions).map do |label|
            {
              id: entry, # TODO: rename
              attribute: label
            }
          end
        end
        # json.properties (cell of a column)
        {
          propertyId: api, # TODO: rename
          propertyLabel: 'TODO: probably notused', # TODO: rename
          propertyKey: source, # TODO: rename
          attributes: cells # TODO: rename
        }
      end
      # json (primary ID and corresponding columns)
      {
        id: query, # TODO: rename
        label: labels[query], # TODO: rename
        properties: cols # TODO: rename (attributes?)
      }
    end
  end

  def find_labels(target, queries)
    fields = '"classification", "classification_label"'
    models = Attribute.where(dataset: target)
    models.first.to_model_class.select(fields)
          .union(*models.map { |x| x.table.select(fields).distinct.where(classification: queries) })
          .pluck(:classification, :classification_label)
          .to_h
  end
end
