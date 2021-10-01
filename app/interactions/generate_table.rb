class GenerateTable < ApplicationInteraction
  string :target

  array :queries do
    string
  end

  array :filters, default: [] do
    hash do
      string :attribute
      array :nodes, default: nil do
        string
      end
    end
  end

  array :annotations, default: [] do
    hash do
      string :attribute
      string :node, default: nil
    end
  end

  def execute
    datasets = (filters + annotations).map(&:attribute)
                                     .uniq
                                     .map { |x| Attribute.from_api(x).dataset }
                                     .grep_v(target)

    entry_cache = datasets.map do |key|
      value = Relation.where(db1: key, db2: target, entry2: queries)
                      .pluck(:entry2, :entry1)
                      .group_by { |x| x[0] }
                      .map { |k, v| [k, v.map { |x| x[1] }] }
                      .to_h

      [key, value]
    end.to_h

    labels = find_labels(target, queries)

    # replace with children categories
    annons = annotations.map do |annotation|
      attribute = annotation[:attribute]
      node = annotation.delete(:node)

      table = Attribute.from_api(attribute).table
      annotation[:nodes] = node ? table.sub_categories(node).push(node) : table.default_categories

      annotation
    end

    queries.map do |query|
      cols = (filters + annons).map do |hash|
        api = hash[:attribute]

        attribute = Attribute.from_api(api)
        table = attribute.table
        source = attribute.dataset

        # primary (target) ID may corresponds to multiple (source) IDs
        entries = if source != target
                    entry_cache[source][query] || []
                  else
                    [query]
                  end

        cells = entries.flat_map do |entry|
          # json.properties.attributes (usually one but map for safe)
          table.labels(entry, hash[:nodes]).map do |label|
            {
              id: entry, # TODO: rename
              attribute: label
            }
          end
        end.uniq
        # json.properties (cell of a column)
        {
          attribute: api, # TODO: rename
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
    models = Attribute.where(dataset: target)
    models.first.to_model_class.select(:identifier, :label)
          .distinct
          .union(*models.map { |x| x.table.find_labels(queries) })
          .pluck(:identifier, :label)
          .to_h
  end
end
