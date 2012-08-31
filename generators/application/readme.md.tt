# Getting Started with Iridium

Iridium is a tool chain for clientside MVC applications. It contains 
everything you need to get going from asset compilation, testing, deploying,
and a live development envrionment. Your application is essentially a
set of files that are compiled into a single static directory that
can be served using any webserver.

## Application Organization

Default directory structure:

```
├── app
│   ├── assets
│   │   └── images
│   ├── config
│   │   ├── development.coffee
│   │   ├── initializers
│   │   ├── production.coffee
│   │   └── test.coffee
│   ├── index.html.erb
│   ├── javascripts
│   │   ├── app.coffee
│   │   ├── boot.coffee
│   │   ├── controllers
│   │   ├── models
│   │   └── views
│   ├── locales
│   │   └── en.yml
│   ├── stylesheets
│   │   └── app.scss
│   └── templates
├── application.rb
├── config
│   ├── development.rb
│   ├── production.rb
│   ├── settings.yml
│   └── test.rb
├── readme.md
├── test
│   ├── controllers
│   ├── integration
│   │   └── navigation_test.coffee
│   ├── models
│   ├── support
│   │   ├── helper.coffee
│   │   └── sinon.js
│   ├── templates
│   ├── unit
│   │   └── truth_test.coffee
│   └── views
└── vendor
    ├── javascripts
    │   ├── handlebars.js
    │   ├── i18n.js
    │   ├── jquery.js
    │   └── minispade.js
    └── stylesheets
```

## Up and Running

You can start a simple application server by entering your project's root
directoy and running this command:

```
$ iridium server
```

## Asset Compilation

Iridium compiles all your source files into a single `application.js` and 
`application.js` files. You can write your application using Javascript or
Coffeescript. Write your CSS using SCSS. All files are wrapped in Minispade
modules. All the source files needed to build your application live in `app`.

* `app/config/*.js`: customization for the current environment

* `app/config/initializers`: files that are not environment specific

* `app/javascripts`: all individual Javascript or Coffesscript 
  source files. Files are generated into minispade modules based on 
  their file name.

* `app/stylesheets`: all individual SCSS files.

* `app/assets`: all files are copied into the generated `site` folder

* `app/templates`: Handlebars templates live here.

* `vendor/javascripts`: Javascript or Coffeescript files that you want to include
  in your pipeline. These files are accessible via `requie`

* `vendor/stylesheets`: External stylesheets you want to include in your application.

### Module Naming

Javascript and Coffeescript files inside `app/javascripts` and `app/vendor/javascripts`
are compiled into minispade modules. The module name is passed on the file name. Here
are some examples. Assume your application is named: "todos".

```
app/javascripts/views.js -> require('todos/views')
app/javascripts/controllers/application_controller.js -> require('todos/controlllers/application_controller')
```

## Running Tests

You can run your applications test without having to do anything. Navigate to 
to your project's root and run this command:

```
$ iridium test
```

There are two different test modes: integration and unit. Integration tests execute
aganist a booted version of your app. Unit tests load your application code so
it can be tested in isolation form the other components. All tests live in the `test`
directory. Files in `test/integration` are considered integration tests. All other tests
are unit tests. 
