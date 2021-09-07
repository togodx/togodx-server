Rails.application.routes.draw do
  match '/breakdown/:api', to: 'application#dispatch_breakdown', via: [:get, :post]
  match '/aggregate', to: 'application#aggregate', via: [:get, :post]
  match '/dataframe', to: 'application#dataframe', via: [:get, :post]
end
