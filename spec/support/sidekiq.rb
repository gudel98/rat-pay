RSpec.configure do |config|
  config.before do
    Sidekiq::Worker.clear_all
  end
end
