# yaml_extend

Extends YAML to support file based inheritance,
to e.g. to build a configuration hierachy.

It is possible to build inheritance trees like
```
default.yml   english.yml          default.yml   german.yml         de.yml
         \    /                             \    /                    |
          uk.yml                            de.yml                  at.yml
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yaml_extend'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install yaml_extend

## Usage
yaml_extend adds the method YAML#ext_load_file to YAML.

This method works like the original YAML#load_file, by extending it with file inheritance.

### Examples


```
# start.yml
extends: 'super.yml'
data:
    name: 'Mr. Superman'
    age: 134    
    favorites:
        - "Raspberrys"
```

```
# super.yml
data:
    name: 'Unknown'
    power: 2000
    favorites:
        - "Bananas"
        - "Apples"
```

YAML.ext_load_file('start.yml')

results in

```
data:
    name: 'Mr. Superman'
    age: 134
    power: 2000
    favorites:
        - "Bananas"
        - "Apples"
        - "Raspberrys"
```

## Doc
YAML#ext_load_file(yaml_path, inheritance_key='extends', extend_existing_arrays=true, config = {})

- *yaml_path* relative or absolute path to yaml file to inherit from
- *inheritance_key* you can overwrite the default key, if you use it already as part of your configuration. The inheritance_key is NOT included in the final merged file. Default: 'extends'
- *extend_existing_arrays* Extends existing arrays in yaml structure instead of replacing them. Default: true
- *config* only intended to be used by the method itself due recursive algorithm

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/entwanderer/yaml_extend. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

