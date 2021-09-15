class ApplicationController < ActionController::API
  # GET /breakdown/:api
  # POST /breakdown/:api
  def breakdown
    parameters = {
      attribute: params[:api], # rename to attribute? api_id => attribute_id
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
      target: params[:togoKey], # TODO: rename to target? subject? map_to? togokey?
      filters: JSON.parse(params[:properties] || '[]').map(&:symbolize_keys) # TODO: rename to params[:filters]
    }

    aggregate = FilterIdentifiers.run(parameters)

    render_json aggregate.result, status: aggregate.valid? ? :ok : :bad_request
  end

  # GET /dataframe
  # POST /dataframe
  def dataframe
    parameters = {
      target: params[:togoKey], # TODO: rename to target? subject? map_to? togokey?
      queries: JSON.parse(params[:queryIds] || '[]'), # TODO: rename to params[:queries]
      filters: JSON.parse(params[:properties] || '[]').map(&:symbolize_keys) # TODO: rename to params[:filters]
    }

    dataframe = GenerateTable.run(parameters)

    render_json dataframe.result, status: dataframe.valid? ? :ok : :bad_request
  end

  # GET /locate
  # POST /locate
  def locate
    parameters = {
      api: params[:sparqlet].sub(/.*\//, ''),
      target: params[:primaryKey],
      source: params[:userKey],
      queries: params[:userIds].split(/,\s*/),
      node: params[:categoryIds].presence # nil or one
    }

    location = LocateIdentifiers.run(parameters)

    render_json location.result, status: location.valid? ? :ok : :bad_request
  end

  private

  def render_json(body, status: :ok)
    render (params.key?(:pretty) ? :pretty_json : :json) => body, status: status
  end
end
