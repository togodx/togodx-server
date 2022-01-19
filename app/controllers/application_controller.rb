class ApplicationController < ActionController::API
  # GET /breakdown/:attribute
  # POST /breakdown/:attribute
  def breakdown
    breakdown = CountBreakdown.run(breakdown_params)

    render_json breakdown.result, status: breakdown.valid? ? :ok : :bad_request
  end

  # GET /locate
  # POST /locate
  def locate
    params = locate_params

    location = LocateIdentifiers.run(attribute: params[:attribute],
                                     source: params[:dataset],
                                     queries: JSON.parse(params[:queries] || '[]'),
                                     node: params[:node].presence)

    render_json location.result, status: location.valid? ? :ok : :bad_request
  end

  # GET /aggregate
  # POST /aggregate
  def aggregate
    params = aggregate_params

    aggregate = FilterIdentifiers.run(target: params[:dataset],
                                      filters: JSON.parse(params[:filters] || '[]').map(&:symbolize_keys),
                                      queries: JSON.parse(params[:queries] || '[]'))

    render_json aggregate.result, status: aggregate.valid? ? :ok : :bad_request
  end

  # GET /dataframe
  # POST /dataframe
  def dataframe
    parameters = {
      target: params[:togokey], # TODO: rename to target? subject? map_to? togokey?
      queries: JSON.parse(params[:queries] || '[]'),
      filters: JSON.parse(params[:filters] || '[]').map(&:symbolize_keys),
      annotations: JSON.parse(params[:annotations] || '[]').map(&:symbolize_keys)
    }

    dataframe = GenerateTable.run(parameters)

    render_json dataframe.result, status: dataframe.valid? ? :ok : :bad_request
  end

  private

  def breakdown_params
    params
      .permit(:attribute, :node)
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

  def render_json(body, status: :ok)
    render (params.key?(:pretty) ? :pretty_json : :json) => body, status: status
  end
end
