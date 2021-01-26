# yaml_extend
![Gem](https://img.shields.io/gem/v/yaml_extend?color=default&style=plastic&logo=ruby&logoColor=red)
![Gem](https://img.shields.io/gem/dt/yaml_extend?color=blue&style=plastic)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg?style=plastic&logo=mit)](LICENSE)

> Extends YAML to support file based inheritance.

That can be very handy to build a configuration hierarchy.

Basic support for ERB (embedded ruby) is included and automatically applied when config files are named `*.erb` or `*.erb.*`.

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
fruits.yml   vegetables.yml          default.yml   extensions.yml       
         \    /                             \    /                
          food.yml                          merged.yml
                                              |
                                            another_extended.yml
```

A file can inherit from as many as you want. Trees can be nested as deep as you want.

YAML files are deep merged, the latest specified child file overwrites the former ones.
Array values are merged as well by default. You can specifiy this with the 3rd Parameter.

The files to inherit from are specified by the key 'extends:' in the YAML file.
That key can be customized if you prefer another one.
See the examples below.

## Usage
yaml_extend adds the method YAML.ext_load_file to YAML.

This method works like the original YAML.load_file, by extending it with file inheritance.

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

When you then call `ext_load_file`

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
You can specify the key by parameter, this is the way to go if you want to  use the different key only once or you use the `ext_load_file` method only once in your application.
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
To reset the global inheritance key, you can either set it to nil or call the `reset_load_key`  method.
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
```ruby
YAML.ext_load_file(yaml_path, inheritance_key='extends', options = {})
```
- `yaml_path` (String) relative or absolute path to yaml file to inherit from
- `inheritance_key` (String) you can overwrite the default key, if you use the default 'extends' already as part of your configuration. The inheritance_key is NOT included, that means it will be deleted, in the final merged file. Default: `'extends'`
- `options` (Hash) collection of optional options, including all options of the based `deep_merge` gem
  - `:preserve_inheritance_key` (Boolean) Preserve inheritance key(s) from resulting yaml, does most time not make sense especially in multiple inheritance - DEFAULT: false
  - The following options are deep merge options that can be passed by - but the defaults differ from original
    https://github.com/danielsdeleo/deep_merge#options
  - `:preserve_unmergeables` (Boolean) Set to true to skip any unmergeable elements from source - DEFAULT: false
  - `:knockout_prefix` (String) Set to string value to signify prefix which deletes elements from existing element - DEFAULT: nil
  - `:overwrite_arrays` (Boolean) Set to true if you want to avoid merging arrays - DEFAULT: false
  - `:sort_merged_arrays` (Boolean) Set to true to sort all arrays that are merged together - DEFAULT: false
  - `:unpack_arrays` (String) Set to string value to run "Array::join" then "String::split" against all arrays - DEFAULT: nil
  - `:merge_hash_arrays` (Boolean) Set to true to merge hashes within arrays - DEFAULT: false
  - `:extend_existing_arrays` (Boolean) Set to true to extend existing arrays, instead of overwriting them - DEFAULT: true
  - `:merge_nil_values` (Boolean) Set to true to merge nil hash values, overwriting a possibly non-nil value - DEFAULT: false
  - `:merge_debug` (Boolean) Set to true to get console output of merge process for debugging - DEFAULT: false

See also rubydoc at [https://www.rubydoc.info/gems/yaml_extend](https://www.rubydoc.info/gems/yaml_extend)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magynhard/yaml_extend. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

