Rails.application.routes.draw do
  match '/breakdown/:attribute', to: 'application#breakdown', via: [:get, :post]
  match '/aggregate', to: 'application#aggregate', via: [:get, :post]
  match '/dataframe', to: 'application#dataframe', via: [:get, :post]
  match '/locate', to: 'application#locate', via: [:get, :post]
end
