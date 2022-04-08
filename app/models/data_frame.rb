class DataFrame
  attr_reader :target
  attr_reader :queries

  # @param [String] target
  # @param [Array<String>] queries
  # @param [Array<Hash>] columns attributes, nodes
  # @param [Hash] options
  def initialize(target, queries, columns, **options)
    @target = target
    @queries = queries
    @columns = columns.map(&:symbolize_keys)
    @columns_cache = {}
    @entry_cache = {}
  end

  def to_json
    @queries.map do |query|
      {
        index: {
          dataset: @target,
          entry: query,
          label: labels[query]
        },
        attributes: @columns.map do |name|
          {
            id: name[:attribute],
            items: (column(name)[:entries][query] || {}).reject { |_, v| v.blank? }.flat_map do |entry, nodes|
              nodes.map do |node|
                {
                  dataset: column(name)[:dataset],
                  entry: entry,
                  node: node[:node],
                  label: node[:label],
                }
              end
            end
          }
        end
      }
    end
  end

  private

  def labels
    return @labels if @labels

    attributes = Attribute.where(dataset: @target)

    return (@labels = {}) unless (attribute = attributes.first)

    @labels = attribute.to_model_class
                       .select(:identifier, :label)
                       .distinct
                       .union(*attributes.map { |x| x.table.find_labels(@queries) })
                       .pluck(:identifier, :label)
                       .to_h
  end

  def column(column)
    return @columns_cache[column] if @columns_cache.key?(column)

    attr = Attribute.from_api(column[:attribute])
    dataset = attr.dataset
    model = attr.table

    entries = if @target == dataset
                @queries.map { |x| [x, [x]] }.to_h
              else
                @entry_cache[dataset] ||= Relation.from_pair(dataset, @target)
                                                  .table
                                                  .convert(dataset, @target, @queries, reverse: true)
              end

    attributes = model
                   .labels(entries.values.flatten.uniq, column[:nodes])
                   .group_by { |attribute| attribute[:id] }
                   .map { |id, group| [id, group.map { |v| { node: v[:node], label: v[:label] } }] }
                   .to_h

    @columns_cache[column] = {
      dataset: dataset,
      entries: entries.map { |k, v| [k, v.map { |id| [id, attributes[id]] }.to_h] }.to_h,
    }
  end
end
