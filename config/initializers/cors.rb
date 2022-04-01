if ENV['RAILS_CORS_ENABLED'].present? && !%w[0 f false].include?(ENV['RAILS_CORS_ENABLED'].downcase)
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'

      resource '*',
               headers: :any,
               methods: [:get, :post, :options, :head]
    end
  end
end
