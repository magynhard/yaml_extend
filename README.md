# yaml_extend

Extends YAML to support file based inheritance.

That can be very handy to build a configuration hierachy.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yaml_extend'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install yaml_extend

## Common information

It is possible to build inheritance trees like:
```
     defaults.yml
  ________\_________
  \        \        \
 dev.yml  int.yml  prod.yml
```
or like this:
```
default.yml   english.yml          default.yml   german.yml
         \    /                             \    /
          uk.yml                            de.yml
                                              |
                                            at.yml
```

A file can inherit from as many as you want. Trees can be nested as deep as you want.

YAML files are deep merged. Two methods are supported:
- :breadthfirst: the latest specified child file overwrites the former ones, uses deep_merge
- :postorder   : the tree is traversed in a postorder fashion, where the newer node gets merged into the existing merge, uses deep_merge!
Array values are merged as well by default. You can specifiy this with the 3rd Parameter.

The files to inherit from are specified by the key 'extends:' in the YAML file.
That key can be customized if you prefer another one.
See the examples below.

## Usage
yaml_extend adds the method YAML#ext_load_file to YAML.

This method works like the original YAML#load_file, by extending it with file inheritance.

### Examples

#### Basic Inheritance
Given the following both files are defined:

```yaml
# start.yml
extends: 'super.yml'
data:
    name: 'Mr. Superman'
    age: 134
    favorites:
        - 'Raspberrys'
```

```yaml
# super.yml
data:
    name: 'Unknown'
    power: 2000
    favorites:
        - 'Bananas'
        - 'Apples'
```

When you then call #ext_load_file

```ruby
config = YAML.ext_load_file 'start.yml'
```

the returned YAML value results in

```yaml
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

If you want to inherit from several files, you can specify a list (Array) of files.
They are merged from top to bottom, so the latest file "wins" - that means it overwrites duplicate values if they exist with the values in the latest file where they occur.

```yaml
extends:
    - 'super_file.yml'
    - 'parent_file.yml'
...
```

#### Using custom extend key

If you don't want to use the default key 'extends:', you can specify your own custom key in two ways.

```yaml
#custom1.yml
inherit_from:
    - 'super_file.yml'
foo: 'bar'
...
```
##### 1. Specify by parameter
You can specify the key by parameter, this is the way to go if you want to  use the different key only once or you use the #ext_load_file method only once in your application.
```ruby
config = YAML.ext_load_file 'custom1.yml', 'inherit_from'
```
##### 2. Global configuration of the key
You can specify the key by configuration globally. So you only need to set the key once and not as parameter anymore
```ruby
YAML.ext_load_key = 'inherit_from'
config = YAML.ext_load_file 'custom1.yml'
```
##### Reset the global key
To reset the global inheritance key, you can either set it to nil or call the #reset_load_key  method.
```ruby
YAML.reset_load_key # more readable
YAML.ext_load_key = nil # more explicit
```
#### Using custom nested extend key
```yaml
#custom2.yml
options:
    extend_file: 'super_file.yml'
    database: false
foo: 'bar'
...
```

```ruby
config = YAML.ext_load_file 'custom2.yml', ['options','extend_file']
```

## Documentation
YAML#ext_load_file(yaml_path, inheritance_key='extends', extend_existing_arrays=true, config = {}, tree_traversal: :breadthfirst))

- *yaml_path* relative or absolute path to yaml file to inherit from
- *inheritance_key* you can overwrite the default key, if you use the default 'extends' already as part of your configuration. The inheritance_key is NOT included, that means it will be deleted, in the final merged file. Default: 'extends'
- *extend_existing_arrays* Extends existing arrays in yaml structure instead of replacing them. Default: true
- *config* only intended to be used by the method itself due recursive algorithm
- *tree_traversal* :breadthfirst or :postorder. Default: :breadthfirst

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magynhard/yaml_extend. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

