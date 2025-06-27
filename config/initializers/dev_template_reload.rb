# This force to clear the cache between all calls in development, preventing needing to restart the server to see changes

if Rails.env.development?
  ActionView::Resolver.caching = false
  Rails.application.config.to_prepare do
    ActionView::LookupContext::DetailsKey.clear
  end
end
