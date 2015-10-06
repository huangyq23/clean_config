#clean_config

A simple configuration library for Ruby projects.

## Installation

Add this line to your application's Gemfile:

    gem 'clean_config'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install 'clean_config'

## Usage

By convention, configuration lives in a single file: `config/config.yml`.

You can put any data you want in this file and access that data in one of three ways:

```yaml
# config/config.yml
 :foo:
   :bar: 'baz'
```

```ruby
require 'clean_config'

class MyClass
  include CleanConfig::Configurable

  def initialize()
    config = CleanConfig::Configuration.instance
    config[:foo][:bar]          # 'baz'
    config.foo.bar              # 'baz'
    config.parse_key('foo.bar') # 'baz'
  end
end
```

### Conventions
Loading configuration data in Ruby is easy. In fact, it is so easy that if you look at several different Ruby projects,
you'll likely find several different implementations for loading configuration. We decided to standardize how we would 
load our configuration across all our gems.

This library requires your configuration be stored in a single yml file, located at

`config/config.yml`

### Loading Configuration
Including the `Configurable` module is what initializes the `Configuration` object with the data from `config/config.yml`.
Simply include this module and your configuration will be available via `CleanConfig::Configuration.instance`.

If you are using the CleanConfig outside of a module or class, there are a few methods available to you
to point CleanConfig to your configuration directory.

`add!` allows you to change the directory/file name for your configuration files.

`load!` looks for the default directory/file name (`config/config.yml`) but at the same level as the calling code.

`merge!` allows you to pass in a hash of additional configuration to add to your CleanConfig.

### Accessing Configuration
After `include CleanConfig::Configurable` you can access your config with: `CleanConfig::Configuration.instance`.
This will have all of your project's configuration and any configuration defined in dependencies.

To get access to the underlying `Hash` methods prefix them with `to_hash` or `to_h`, e.g. `config.to_h.values`.

Note: We have added a `#keys` method also.
As a result, if you have a field called `:keys:` in your config file the only way to access it is `config.to_h[:keys]`

### Layering Configuration
If you depend on gems that are using clean_config, you can override their key-value pairs in your own `config/config.yml`. 
Also, it's a good idea to nest your configuration under some top-level, project-specific key to prevent accidental 
configuration collisions.

## Contributing

#### Contacts
+ Adrian Cazacu
+ CivJ
+ Crystal Hsiung

#### Process
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
