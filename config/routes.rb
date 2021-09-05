Rails.application.routes.draw do
  match '/breakdown/:api', to: 'application#dispatch_breakdown', via: [:get, :post]
  match '/dataframe', to: 'application#generate_dataframe', via: [:get, :post]
end
