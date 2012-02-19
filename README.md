# FrontendServer: A Simple Server for JS Frontend Development

The title says it all. It is basically some glue code to connect
different moving parts to provide:

1. Asset Compilation (JS/Coffeescript/CSS/SASS/SCSS and friends)
2. Asset Concatenation and Minification
3. API proxying to avoid CORS in development and production
4. A Rack app to serve the frontend
5. Different configuration enviroments (development & production)

You can easily deploy these applications to Heroku.

## Directory Structure

This code assumes a few things. First, let's start with the directory
structure.

```
|- app/
|---- javascripts/
|---- stylesheets/
|---- images/
|---- public/
|---- vendor/
|------- stylesheets/
|------- javascripts/
|- config/
|---- application.yml
|---- environment.rb
|- Rakefile
|- application.rb
|- config.ru
```

`app` holds all the code needed to compile the application.

`app/javascripts` contains only js or cofeescript files. Use the
directory structure to create a module system. For example,
`app/javascripts/views/my_view.js` would create a minispade module
named: `#{application_name}/views/my_view`.

`app/stylsheets` contains all the css/scss/sass files. You can create
your own subdirectory structure if you want. 

`app/images` all the images.

`app/public` the contents of this directory are copied into the output
directory.

`app/vendor/stylesheets` stylesheets not written by you. Read: twitter
bootstrap and jquery ui.

`app/vendor/javascripts` JS files written by other people. Examples,
Backbone, Ember, jQuery, jQueryUi etc. Use the minified versions. All
files will be turned into minispade modules. Example:
`app/vendor/javascripts/ember.js` will become simply `ember`.

`app/config/application.yml` configuration values.

`app/config/environment.rb` global server configuration

`Rakefile` defines rake tasks

`application.rb` defines your application

`config.ru` rack up!

## Up and Running

First thing: create the directory structure in `app`. 

```
mkdir app
mkdir app/javascripts
mkdir app/stylesheets
mkdir app/vendor/
mkdir app/vendor/javascripts
mkdir app/vendor/stylesheets
mkdir app/public
```

Now setup the other files:

```
touch Gemfile
touch application.rb
touch Rakefile
touch config.ru
```

In your `Gemfile`:

```ruby
# Gemfile

source :rubygems

gem "frontend_server"

# NOTE: For the time being, you have to use git repos. Rake pipeline 0.6
# has not been released yet and rake-pipeline-web-filters depends on that
# version.
gem "rake-pipeline", :git => "git://github.com/livingsocial/rake-pipeline.git"
gem "rake-pipeline-web-filters", :git => "git://github.com/wycats/rake-pipeline-web-filters.git"
```

Your Javascript will be compfiled into minispade modules based on the
class name and path. For example, if your appilcation class name is
`Todos`, then javascripts will be prefixed with as `todos/file_name`.
Create a subclass of `FrontendServer::Application` with your application
name.

```ruby
# application.rb

require 'frontend_server'

class Todos < FrontendServer::Application

# Tell the server where to locate the files

Todos.root = File.dirname __FILE__ 
```

Now, tell Rack to run a new Todo app. 

```ruby
# config.ru

require './application'

run Todos.new
```

Now, create a rake file so you can compile assets at deploy time

```ruby
require './application'

namespace :assets do
  task :precompile do
    # Remeber to set the class name correctly
    app = Todos.new.
    app.reset!
    app.project.invoke
  end
end
```

Now you can start the development server like this:

```
$ bundle exec rackup
```

## Example

I've translated the classic backbone todos app into an example. Code
[here](https://github.com/Adman65/frontend_server_example)


## Using

```
bundle exec rackup # start the server
bundle exec rake assets:precompile # compile all assets in public/
```

## Configuration

`config/application.yml` contains all configuration values. `server` is
the only required key. All other keys are translated to method names.
For example, this config file:

```yml
development:
  server: "http://api.example.com"
  developer_key: "foo"
  user_api_key: "bar"
```

Would create:

```ruby
Todos.config.server
Todos.config.developer_key
Todos.config.user_api_key
```

## Initialization & Enviroment Files

`config/environment.rb` holds any global settings. It is required first
if it exists.

FrontendServer also allows you customize settings through environment
files. `config/development.rb` and `config/production.rb` will be
required if they exist.

## Configuration

You can hook into the Rack builder process at the beginning. Here's an
exmaple:

```ruby
Todo.configure do |rack, config|
  rack.use MyCustomMiddleWare.new config.value
end
```

## API Proxy

The server also includes a simple proxy for your API. Configure the `server`
value in `application.yml` first. All requests `/api` are proxied to the
API server. For example, if you request `/api/todos` and server is set
to `api.example.com`, the resulting request would be:
`http://api.example.com/todos`.

## Extras

I've included a simple middleware you can use to add headers to
requests. I've included this because our API uses headers to
authenticate keys. This way I can keep the API key hidden from the
public and proxy it to the API through this rack app. 

Here's an example:

```yml
development:
  server: "http://api.example.com"
  developer_key: "foo"
  user_api_key: "bar"
```

```ruby
# config/enviroment.rb

Todos.configure do |rack, config|
  rack.use FrontendServer::AddHeader.new 'X-Application-Auth-Token', config.developer_key
end
```

## Deploying

Applications built using FrontendServer can be deployed to heroku out of
the box. Applications will be compiled and **minified** at deploy time. 

```
heroku create --stack cedar
git push master heroku
heroku open
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
