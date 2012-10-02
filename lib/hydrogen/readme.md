# Writing Commands

Commands are individual Thor classes that implement small bits of
functionality. Components can load commands. Loaded commands will be
accessible via a `Hydrogen::CLI` class.

Here's an example:

```ruby
# First: write your command
class HelloWorld < Hydrogen::Command
  # thor stuff
  def hello(msg)
    puts msg
  end
end

# Second: connect it with a component
# greeter.rb
class Greeter < Hydrogen::Component
  command HelloWorld, :hello, description, help
end

# Third: setup the CLI
# cli.rb
require 'hydrogen'
require 'gretter' # loads the greeter component

class MyCLI < Hydrogen::CLI

end

MyCLI.run
```

```
# Finally in the shell
$ ruby ./cli hello Adam
```

Now any number of external or internal libraries can augment your main
CLI. All CLI classes inherit from Thor so everything is available.
