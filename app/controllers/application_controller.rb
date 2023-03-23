class ApplicationController < ActionController::API
  # GET /breakdown/:attribute
  # POST /breakdown/:attribute
  def breakdown
    breakdown = CountBreakdown.run(breakdown_params)

    if breakdown.valid?
      render_json breakdown.result
    else
      render_json({ errors: breakdown.errors.full_messages }, status: :bad_request)
    end
  end

  # GET /suggest/:attribute
  # POST /suggest/:attribute
  def suggest
    suggest = SuggestTerm.run(suggest_params)

    if suggest.valid?
      render_json suggest.result
    else
      render_json({ errors: suggest.errors.full_messages }, status: :bad_request)
    end
  end


  # GET /locate
  # POST /locate
  def locate
    params = locate_params

    location = LocateIdentifiers.run(attribute: params[:attribute],
                                     source: params[:dataset],
                                     queries: JSON.parse(params[:queries] || '[]'),
                                     node: params[:node].presence)

    if location.valid?
      render_json location.result
    else
      render_json({ errors: location.errors.full_messages }, status: :bad_request)
    end
  end

  # GET /aggregate
  # POST /aggregate
  def aggregate
    params = aggregate_params

    aggregate = FilterIdentifiers.run(target: params[:dataset],
                                      filters: JSON.parse(params[:filters] || '[]').map(&:symbolize_keys),
                                      queries: JSON.parse(params[:queries] || '[]'))

    if aggregate.valid?
      render_json aggregate.result
    else
      render_json({ errors: aggregate.errors.full_messages }, status: :bad_request)
    end
  end

  # GET /dataframe
  # POST /dataframe
  def dataframe
    params = dataframe_params

    dataframe = GenerateTable.run(target: params[:dataset],
                                  queries: JSON.parse(params[:queries] || '[]'),
                                  filters: JSON.parse(params[:filters] || '[]').map(&:symbolize_keys),
                                  annotations: JSON.parse(params[:annotations] || '[]').map(&:symbolize_keys))

    if dataframe.valid?
      render_json dataframe.result
    else
      render_json({ errors: dataframe.errors.full_messages }, status: :bad_request)
    end
  end

  private

  def breakdown_params
    params
      .permit(:attribute, :hierarchy, :node, :order)
      .to_h
      .symbolize_keys
      .tap { |hash| hash.merge!(hierarchy: hash.key?(:hierarchy)) }
  end

  def suggest_params
    params
      .permit(:attribute, :term)
      .to_h
      .symbolize_keys
  end

  def locate_params
    params
      .permit(:attribute, :node, :dataset, :queries)
      .to_h
      .symbolize_keys
  end

  def aggregate_params
    params
      .permit(:dataset, :filters, :queries)
      .to_h
      .symbolize_keys
  end

  def dataframe_params
    params
      .permit(:dataset, :filters, :annotations, :queries)
      .to_h
      .symbolize_keys
  end

  def render_json(body, status: :ok)
    render (params.key?(:pretty) ? :pretty_json : :json) => body, status: status
  end
end
