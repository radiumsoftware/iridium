namespace :assets do
  desc "Compiles assets for production use"
  task :precompile do
    ENV['RACK_ENV'] = 'production'
    Iridium.load!
    Iridium.application.boot! unless Iridium.application.booted?
    Iridium.application.compile
  end
end
