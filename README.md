# Iridium: A Toolchain for JS Development

Iridium is a tool to help you with modern Javascript development. It's
here to make you a faster developer and solve common problems. It
focuses primarily on:

* CLI driven interactions
* Expose as little Ruby as possible
* Focus on JS/CSS/HTML
* Make JS testable

## Getting Started

Iridium support the most common use case right out of the box. You have
a directory of assets that need to be compiled into a web application.
Iridium uses `Rake::Pipeline` and sensible defaults to make writing
structured and testable Javascript possible. The first step is to use
the built in generator to create the structure:

```
$ irdium new todos
    create  app
    create  app/dependencies
    create  app/images
    create  app/javascripts/app.coffee
    create  app/public
    create  app/stylesheets/app.scss
    create  app/vendor/javascripts
    create  app/vendor/stylesheets
    create  test/test_helper.coffee
    create  test/integration/truth_test.coffee
    create  test/unit/truth_test.coffee
    create  test/support
    create  site
    create  application.rb
```

Now your pipeline is ready. You can use the built in development server
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

## Running Tests

Iridium makes testing your JS easy. It does all the manual work for you.
It also unites your integration and unit tests into a single test suite.

```
$ iridium test
Run options: --seed 9851

# Running Tests:

.................................................................

2998 Test(s), 2998 Assertion(s), 2998 Passed, 0 Error(s), 0 Failure(s)
```

Integration tests use CasperJS and unit tests use qUnit. Stub tests are
generated with your application. These tests should pass out of the box
given you have the proper CapserJS version installed. All your tests are
run through the `iridium test` command. Here are some examples:

```
$ iridium test test/integration/foo.js
$ iridium test test/unit/bar.js
$ iridium test test/integration/* test/models/*
$ iridium test test/**/*_test.coffee
$ iridium test test/**/*_test.{coffee,js} # this is the default!
```


## Customizing the Asset pipeline

You may want to change the way assets are compiled. Iridium uses it's
own pipeline by default. You can override this by creating your
`Assetfile` inside the root directory. You can start with a blank slate,
or use a generator. The generator creates an `Assetfile` that does the
same thing as the internal pipeline. You may also access the `app`
method.

```
$ cd todos
$ iridium generate assetfile
    create Assetfile
```

## Customizing index.html

`index.html` is an annoying part of web development. You cannot start or
serve your application without an HTML page to load your JS. Iridium has
a built in `index.html` which loads your assets and dependencies. This
will work for most simple applications. You can override this by
providing your own `index.html` in `public`. You can create the file
yourself or use a generator. The generator creates a file that does the
same thing as the bundled `index.html`.

```
$ cd todos
$ iridium generate index
    create app/public/index.html.erb
```

## Customization per Environment

More complicated applications need to support different environment.
Common envrioments are: development, test, and production. Each
environment may have their own dependencies or tweaks. Usually this is a
pain. Customizations happen at the server level. You **code** should not
be environment specific! Use the generator to create the file structure.

```
$ cd todos
$ iridium generate envs
    create  config/development.rb
    create  config/test.rb
    create  config/production.rb
```

## Deploying

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
