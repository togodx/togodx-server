Rails.application.routes.draw do
  get '/breakdown/:api', to: 'application#dispatch_breakdown'
end
