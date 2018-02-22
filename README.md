# yaml_extend

Extends YAML to support file based inheritance,
to e.g. to build a configuration hierachy.

It is possible to build inheritance trees like
```
default.yml   english.yml          default.yml   german.yml         de.yml
         \    /                             \    /                    |
          uk.yml                            de.yml                  at.yml
```

A file can inherit from as many as you want. Trees can be nested as deep as you want.
The child file overwrites same values if given in the parent file.

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
        - 'Raspberrys'
```

```
# super.yml
data:
    name: 'Unknown'
    power: 2000
    favorites:
        - 'Bananas'
        - 'Apples'
```
#### Basic Inheritance
```
YAML.ext_load_file('start.yml')
```

results in

```
data:
    name: 'Mr. Superman'
    age: 134
    power: 2000
    favorites:
        - 'Bananas'
        - 'Apples'
        - 'Raspberrys'
```

#### Inherit from several files

```
extends:
    - 'super_file.yml'
    - 'parent_file.yml'
...
```

#### Using custom extend key
```
#custom1.yml
inherit_from:
    - 'super_file.yml'
foo: 'bar'
...
```

```
YAML.ext_load_file('custom1.yml','inherit_from')
```
#### Using custom nested extend key
```
#custom2.yml
options:
    extend_file: 'super_file.yml'
    database: false
foo: 'bar'
...
```

```
YAML.ext_load_file('custom2.yml',['options','extend_file'])
```

## Documentation
YAML#ext_load_file(yaml_path, inheritance_key='extends', extend_existing_arrays=true, config = {})

- *yaml_path* relative or absolute path to yaml file to inherit from
- *inheritance_key* you can overwrite the default key, if you use the default 'extends' already as part of your configuration. The inheritance_key is NOT included, that means it will be deleted, in the final merged file. Default: 'extends'
- *extend_existing_arrays* Extends existing arrays in yaml structure instead of replacing them. Default: true
- *config* only intended to be used by the method itself due recursive algorithm

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/entwanderer/yaml_extend. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

