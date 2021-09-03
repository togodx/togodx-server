class ApplicationController < ActionController::API
  def dispatch_breakdown
    api = params[:api]
    node = params[:node]
    mode = params[:mode]
    id = Attribute.api_id(api)
    datamodel = Attribute.api_datamodel(api)
    case datamodel
    when "Classification"
      table = Classification.select_table(id)
    when "Distribution"
      table = Distribution.select_table(id)
    end
    render json: table.breakdown(node, mode)
  end
end
