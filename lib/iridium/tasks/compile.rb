namespace :assets do
  desc "Compiles assets for production use"
  task :precompile do
    ENV['RACK_ENV'] = 'production'
    require File.expand_path("application", Dir.pwd)
    Iridium.application.compile
  end
end
