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
│   ├── dependencies
│   │   └── minispade.js
│   ├── images
│   ├── javascripts
│   │   ├── app.coffee.tt
│   │   ├── boot.coffee.tt
│   │   ├── controllers
│   │   ├── models
│   │   ├── templates
│   │   └── views
│   ├── public
│   ├── stylesheets
│   │   └── app.scss
│   └── vendor
│       ├── javascripts
|       │   ├── jquery.js
|       │   └── handlebars.js
│       └── stylesheets
├── application.rb
├── readme.md
├── site
└── test
    ├── helper.coffee
    ├── controllers
    ├── models
    ├── templates
    ├── integration
    ├── views
    │   └── navigation_test.coffee
    ├── support
    │   ├── qunit.js
    │   └── sinon.js
    ├── unit
        └── truth_test.coffee.tt
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

* `app/dependencies`: global files to be written into `<script>` tags.
  These files are not accessible via `require` and are included before your
  application code. Common example: jquery

* `app/javascripts`: all individual Javascript or Coffesscript 
  source files. Files are generated into minispade modules based on 
  their file name.

* `app/stylesheets`: all individual SCSS files.

* `app/public`: all files are copied into the generated `site` folder

* `app/images`: all files are copied into the generated `site` folder

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
app/vendor/javascripts/jquery.js -> require('jquery')
app/vendor/javascripts/handlebars.min.js -> require('handlerbars')

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
are unit tests. Refer to `test/helper.coffee` and the Iridium documentation for more
information on writing and maintaining tests.
