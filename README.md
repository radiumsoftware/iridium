# Iridium: A Simple Server for JS Frontend Development

The title says it all. It is basically some glue code to connect
different moving parts to provide:

1. Asset Compilation (JS/Coffeescript/CSS/SASS/SCSS and friends)
1. Assets pass through ERB filters for embedding server config
2. Asset Concatenation and Minification
3. API proxying to avoid CORS in development and production
4. A Rack app to serve the frontend
5. Different configuration enviroments (development & production)

All requests that are not for the API and are not for assets are 
rewritten to your main app. For Example,

```
/contacts => /
/contacts/:5 => /
/application.js => /application.js
/foo/public.html => /foo/public.html
```

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
|---- external/
|- config/
|---- settings.yml
|---- application.rb
|- Rakefile
|- application.rb
|- config.ru
```

`app` holds all the code needed to compile the application.

`app/javascripts` contains only js or cofeescript files. Use the
directory structure to create a module system. For example,
`app/javascripts/views/my_view.js` would create a minispade module
named: `#{application_name}/views/my_view`.

`app/stylesheets` contains all the css/scss/sass files. You can create
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

`app/config/settings.yml` configuration values.

`app/config/application.rb` global server configuration

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

gem "iridium", :git => "git://github.com/radiumsoftware/iridium.git"

# NOTE: For the time being, you have to use git repos. Rake pipeline 0.6
# has not been released yet and rake-pipeline-web-filters depends on that
# version.
gem "rake-pipeline", :git => "git://github.com/livingsocial/rake-pipeline.git"
gem "rake-pipeline-web-filters", :git => "git://github.com/wycats/rake-pipeline-web-filters.git"
```

Your Javascript will be compfiled into minispade modules based on the
class name and path. For example, if your appilcation class name is
`Todos`, then javascripts will be prefixed with as `todos/file_name`.
Create a subclass of `Iridium::Application` with your application
name.

```ruby
# application.rb

require 'iridium'

class Todos < Iridium::Application
end
```

Now, tell Rack to run a new Todo app. 

```ruby
# config.ru
require ::File.expand_path('application',  __FILE__)
run Todos
```

Now, create a `Rakefile` so you can compile assets at deploy time

```ruby
require 'iridium/tasks'
```

Now you can start the development server like this:

```
$ bundle exec rackup
```

## Example

I've translated the classic backbone todos app into an example. Code
[here](https://github.com/radiumsoftware/iridium_example)


## Using

```
bundle exec rackup # start the server
bundle exec rake assets:precompile # compile all assets in public/
```

## Configuration

`config/application.yml` contains all configuration values.
All other keys are translated to method names available as
`ApplicationName.config`

Here is an example config file:

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

Iridium also allows you customize settings through environment
files. `config/development.rb` and `config/production.rb` will be
required if they exist.

## Configuration

You can hook into the Rack builder process at the beginning. The
interface is inspired by the Rails middleware interface. Here's an
exmaple:

```ruby
Todos.configure do 
  middleware.use MyCustomMiddleware, 'foo', 'bar', :options => :accepted
end
```

## API Proxy

You can configure any number of proxies to other API's. You can use the
proxy to hide access keys and/or avoid CORs problems. Here is an
example:

```ruby
# config/application.rb

Todos.configure do 
  config.proxy '/radium', 'http://api.example.com'
  config.proxy '/twitter', 'http://api.twitter.com'
  config.proxy '/fb', 'http://horrible-api.facebook.com'
end

## Development

The pipeline is recompiled before each request in development mode.

## Extras

Iridium contains some basic middleware that make it easy to authenticate
to external APIs

```ruby
# config/enviroment.rb

Todos.configure do
  # Add a header: commonly used to authentication/oauth keys
  # :if option can be specified to only send the header for certain requests
  middleware.use Iridium::Middleware::AddHeader.new('X-Application-Auth-Token', config.developer_key, :if => /\/api/)

  # Can add a cookies if you need them
  middleware.use Iridium::Middleware::Addcookie.new('user_api_key', config.api_key')

  # These middleware calls have shortcut methods as well
  middleware.add_header 'Foo', 'bar', :if => /\/api/
  middleware.add_cookie 'Foo', 'bar'
end
```

## Deploying

Applications built using Iridium can be deployed to heroku out of
the box. Applications will be **compiled and minified** at deploy time. 

```
heroku create
git push master heroku
heroku open
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
