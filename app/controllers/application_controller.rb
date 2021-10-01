class ApplicationController < ActionController::API
  # GET /breakdown/:attribute
  # POST /breakdown/:attribute
  def breakdown
    parameters = {
      attribute: params[:attribute], # rename to attribute? api_id => attribute_id
      node: params[:categoryIds], # params[:node]
      mode: params[:mode]
    }

    breakdown = CountBreakdown.run(parameters)

    render_json breakdown.result, status: breakdown.valid? ? :ok : :bad_request
  end

  # GET /aggregate
  # POST /aggregate
  def aggregate
    parameters = {
      target: params[:togokey], # TODO: rename to target? subject? map_to? togokey?
      filters: JSON.parse(params[:filters] || '[]').map(&:symbolize_keys),
      mappings: JSON.parse(params[:queries] || '[]')
    }

    aggregate = FilterIdentifiers.run(parameters)

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

  # GET /locate
  # POST /locate
  def locate
    parameters = {
      attribute: params[:attribute].sub(/.*\//, ''),
      source: params[:togokey],
      queries: params[:queries].split(/,\s*/),
      node: params[:node].presence
    }

    location = LocateIdentifiers.run(parameters)

    render_json location.result, status: location.valid? ? :ok : :bad_request
  end

  private

  def render_json(body, status: :ok)
    render (params.key?(:pretty) ? :pretty_json : :json) => body, status: status
  end
end
