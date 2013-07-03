Please note I cannot release a gem version of iridium until
rake-pipeline releases a new version. This means you must specify git
dependencies in your `Gemfile`.

First create a `Gemfile`

```
source 'https://rubygems.org'

gem 'iridium', :github => 'radiumsoftware/iridium'
gem 'hydrogen', :github => 'radiumsoftware/hydrogen'
gem 'rake-pipeline', :github => 'livingsocial/rake-pipeline'
```

Now bootstrap:

```
$ bundle
$ bundle exec iridium g:application
```

Don't forget you **must use bundle exec!**

# Iridium: A Toolchain for JS Application Development

Iridium is a tool to help you with modern Javascript development. It's
here to make you a faster developer and solve common problems. It
focuses primarily on:

* CLI driven interactions
* Focus on JS/CSS/HTML
* Make JS testable

## Sensible Defaults

Iridium makes choices for you by default. These choices work well
together. All Iridium apps get all this right out of the box:

* Coffeescript
* Sass
* Spriting
* jQuery for DOM manipulation
* Handlebars for templating
* Minispade for simple modules and `require`
* Qunit or Jasmine for unit tests
* GZip assets in production
* Fully cache all assets in production
* Generate an HTML5 cache manifest for production
* i18n

## Getting Started

The first step is to use the built-in generator to create the structure:

```
$ iridium generate app todos
```

Now your application is ready. You can use the built in development server
to edit your JS/CSS files and reload the browser.

```
$ cd todos
$ iridium server
>> Thin web server (v1.4.1 codename Chromeo)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:9292, CTRL+C to stop
```

Navigate to `http://localhost:9292` in your browser and you'll see a
blank canvas.

## Writing Javascript

Iridium compiles all `.coffee` files to `.js`. All files inside
`lib/` and `app/`. All files inside `app` are wrapped in minispade
modules. The module name comes from the file name. `require` calls are
rewritten to use `minispade.require`. Files inside `app/config` and
`app/config/initializers` are also compiled, but not wrapped in
modules. Files inside vendor code are not wrapped in modules. All of
the javascript + templates is concatenated into a single
`application.js`. The compiled `application.js` has this order:

1. `app/config/environment.coffee`
2. Vendored javascript in the specified order
3. The file in `app/config` matching the current environment. Example:
   `app/config/development.coffee` in development or
   `app/config/test.coffee` in tests.
4. All files in `app/config/initializers` wrapped in IFFEs
5. All the files from `lib/` wrapped in minispade modules
6. All the code in `app/javascripts` wrapped in minispade modules
7. I18n code
8. All handlebears templates compiled into Javascript.

You can inspect the final `application.js` to verify everything is
working as you expected.

Here are some examples:

| Path | Module Name | require |
| ---- | ----------- | ------- |
| `app/javascripts/foo.js` | `foo` | `require('foo')` |
| `app/javascripts/controllers/foo_contoller` | `controllers/foo_controller` | `require('controllers/foo_controller')` |
| `lib/framework.js` | `framework` | `require('framework')` |

### Vendored Javascripts

Files in `vendor/javascripts` are included before your application code.
All files in this directory are loaded before your app code in
alphabetical order unless an order is specified. You don't have to
specify the order for all files. You can declare files that should be
included before all others and not worry about the others. For example,
you have 10 files in `vendor/javascripts`. You only care that
`minispade`, `jquery`, and `jquery_ui` are loaded first. All the other
files will be included after those.

```ruby
# application.rb
Todos.configure do
  # load minispade, jquery, jquery_ui, then all other vendored files
  # Note, the symbol refers to the file name without extension. 
  # example: :minispade => vendor/javascripts/minispade.js

  config.dependencies.load :minispade, :jquery, :jquery_ui
end
```

### Loading External Scripts

You may want to pull in external scripts via CDN instead of bundling
them inside your application. Configured scripts are written in as
`<script>` tags before your application code. Here's an example:

```ruby
# application.rb
Todos.configure do
  config.scripts.load "http://www.mycdn.com/script.js"
end
```

## Using SASS

Everything works as you expect. All `.scss` or `.sass` files are
compiled correctly. You can use `@import` as you'd expect.
`app/stylesheets` is added to the sass load path.

## Using Sprites

Create a directory for each set of sprites you need. Then `@import` it
as usual with compass. Here's an example. Create a directory named
`app/sprites/icons`. Dump all the individual icon png's in that
directory. Inside your stylesheet you can write:
`import('icons/*.png')` to generate the icons sprite.

## Writing Templates

Handlebars templates are named using the same semantics as application
javascript. All files `*.hanlebars` and `*.hbs` in `app/templates` are processed.
The templates are also precompiled depending on the environment.

| Path | Template Name |
| ---- | ----------- |
| `app/templates/dashboard.hbs` | `dashboard` |
| `app/templates/dashboard/settings.hbs` | `dashboard/settings` |

## Running Tests

Iridium makes testing your JS easy. It does all the manual work for you.
It compiles all the tests into `tests.js` and `tests.html`. You open
`tests.html` in your browser or use it with phantomjs. The test
command will compile your tests and check them with phantomjs. Qunit
and Jasmine are supported out of the box.

```
$ iridium test

# Running Tests:

.................................................................

2998 Test(s), 2998 Passed, 0 Error(s)
```

You can use `iridium test --debug` if you want to see `console.log`
messages in the report.

## JSLint

Coffescript is generated by default. You can write in Javscript if you
like. Iridium can run all your files through JSLint if you like.

```
$ iridium lint app/javascripts/app.js
$ iridium lint app/javascripts/models/* app/javascripts/controllers/*
$ iridium lint app/javascripts/**/*.js # this is the default!
```

## Localization (I18n)

Iridium supports localization via `i18n.js`. The i18n implementation is
taken from [here](https://github.com/fnando/i18n-js). All files in
`app/locales/*.yml` are merged into i18n translations. Here's an
example:

```yml
# app/locales/en.yml
en:
  greeting: Hello!
```

```yml
# app/locales/fi.yml
fi:
  greeting: Terve!
```

```js
I18n.locale = 'en'
I18n.t('greeting') // "Hello!"
I18n.locale = 'fi'
I18n.t('gretting') // "Terve!"
```

## Advanced Configuration

Iridium is written with Javascript developers in mind. They may not have
experience in ruby. I've tried as much as I can to shield some
complexity from newbies. Each part of Iridium is hidden by default, but
can be generated and customized.

### Configuration, Middleware, and Proxying

Your Iridium app is served as a rack app. You can inject your own
middleware as you like. Here's an example:

```ruby
# application.rb

YourApp.configure do
  # config.middleware mimics the Rack::Builder api
  config.middleware.use MyCustomMiddleware
end
```

Iridium also has basic proxy support for handling your backend API. You
should only use this proxy if the API does not support CORs or there is
some other issue with it. You may want to use this proxy in test mode to
point your app to a test server intead. Here's an example:

```
# application.rb
YourApp.configure do
  proxy "/api", "http://api.myproduct.com"
end
```

Proxies can be overwritten per env like this:

```
# application.rb
YourApp.configure do
  proxy "/api", "http://api.myproduct.com"
end

# config/test.rb
YourApp.configure do
  proxy "/api", "http://test-api.myproduct.com"
end
```

### Customizing The Unit Test Loader

Iridium uses a generated HTML file to load your test code into. You can
override this behavior by creating:
`test/support/unit_test_loader.html.erb`. 

Here's what the default ERB template looks like:

```erb
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Unit Tests</title>

    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
  </head>

  <body>
    <% app.config.dependencies.each do |script| %>
      <script src="<%= script.url %>"></script>
    <% end %>

    <script src="application.js"></script>
  </body>
</html>
```

### Deploying

JS applications are simply a collection of static assets in a diretory.
This is trival to serve up with Rack. Iridium apps are rack apps for
serving up the compiled directory. The server also handles caching,
proxying, and custom middleware. All you need to do is create a
`config.ru` file and you can deploy your app! You can also deploy your
app for free on Heroku out of the box.

```ruby
# config.ru
require File.expand_path('../application', __FILE__)

run MyApp
```

Or if you don't care about that, you can run the generator:

```
$ cd my_app
$ iridium generate rackup
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
