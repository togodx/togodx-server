class ApplicationController < ActionController::API
  # GET /breakdown/:api
  # POST /breakdown/:api
  def dispatch_breakdown
    attribute = params[:api] # rename to attribute? api_id => attribute_id
    node = params[:categoryIds] # params[:node]
    mode = params[:mode]

    render (params.key?(:pretty) ? :pretty_json : :json) => Attribute.from_api(attribute).table.breakdown(node, mode)
  end

  # GET /dataframe
  # POST /dataframe
  def generate_dataframe
    render (params.key?(:pretty) ? :pretty_json : :json) => aggregate_identifiers
  end

  # togokey_filter
  def aggregate_identifiers
    target = params[:togoKey] # params[:dataset] primarykey? subject? target?
    filters = JSON.parse(params[:properties]).map(&:deep_symbolize_keys) # params[:filters]

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
        entries = Relation.convert(source, target, entries).map(&:entry2)
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
