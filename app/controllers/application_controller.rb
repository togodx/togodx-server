class ApplicationController < ActionController::API
  # GET /breakdown/:api
  # POST /breakdown/:api
  def breakdown
    attribute = params[:api] # rename to attribute? api_id => attribute_id
    node = params[:categoryIds] # params[:node]
    mode = params[:mode]

    render (params.key?(:pretty) ? :pretty_json : :json) => Attribute.from_api(attribute).table.breakdown(node, mode)
  end

  # GET /dataframe
  # POST /dataframe
  def dataframe
    # TODO: rename to target? subject? map_to? togokey?
    target = params[:togoKey]
    # TODO: rename to params[:queries]
    queries = JSON.parse(params[:queryIds])
    # TODO: rename to params[:filters]
    filters = JSON.parse(params[:properties]).map(&:deep_symbolize_keys)

    render (params.key?(:pretty) ? :pretty_json : :json) => generate_dataframe(target, queries, filters)
  end

  class TableCache
    def initialize(api)
      @attribute = Attribute.from_api(api)
      @table = @attribute.table
      @source = @attribute.dataset
    end

    def restore
      return [@attribute, @table, @source]
    end
  end

  # GET /aggregate
  # POST /aggregate
  def aggregate
    # TODO: rename to target? subject? map_to? togokey?
    target = params[:togoKey]
    # TODO: rename to params[:filters]
    filters = JSON.parse(params[:properties]).map(&:deep_symbolize_keys)

    render (params.key?(:pretty) ? :pretty_json : :json) => aggregate_identifiers(target, filters)
  end

  # GET /locate
  # POST /locate
  def locate
    api = params[:sparqlet].sub(/.*\//, '')
    target = params[:primaryKey]
    source = params[:userKey]
    queries = params[:userIds].split(/,\s*/)
    node = params[:categoryIds] # nil or one
    if source != target
      queries = Relation.convert(source, target, queries)
    end
    attribute = Attribute.from_api(api)
    render (params.key?(:pretty) ? :pretty_json : :json) => attribute.table.locate(queries, node)
  end

  private

  # togokey_table_data
  def generate_dataframe(target, queries, filters)
    table_cache = {}

    rows = queries.map do |query|
      cols = filters.map do |hash|
        api = hash[:propertyId]
        conditions = hash[:categoryIds]
        # cache/restore an Attribute table
        table_cache[api] ||= TableCache.new(api)
        attribute, table, source = *table_cache[api].restore
        # primary (target) ID may corresponds to multiple (source) IDs
        if source != target
          entries = Relation.convert(source, target, query, reverse: true)
        else
          entries = [query]
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
          propertyLabel: attribute.label, # TODO: rename
          propertyKey: source, # TODO: rename
          attributes: cells # TODO: rename
        }
      end
      # json (primary ID and corresponding columns)
      {
        id: query, # TODO: rename
        label: "TODO: FIXME", # TODO: rename
        properties: cols # TODO: rename (attributes?)
      }
    end
  end

  # togokey_filter
  def aggregate_identifiers(target, filters)
    idsets = filters.select { |x| x.has_key?(:categoryIds) }.map do |hash|
      entries = []

      attribute = Attribute.from_api(hash[:propertyId])
      table = attribute.table
      source = attribute.dataset

      hash[:categoryIds].each do |condition|
        # OR (within a same attribute)
        entries += table.entries(condition)
      end

      if source != target
        entries = Relation.convert(source, target, entries)
      end

      entries.uniq
    end

    # AND (among different attributes)
    idsets.sort! { |a, b| a.size <=> b.size }

    # idset = idsets.shift
    # while idsets.size > 0
    #   other = idsets.shift
    #   idset = idset.intersection(other)
    # end

    idsets.inject { |set, array| set.intersection(array) }
  end
end
