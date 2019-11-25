#!/usr/bin/env ruby

require '../lib/yaml_extend.rb'

# no automated check for now

# new scheme
files=[]
config=YAML.ext_load_file 'd1.yaml', files: files, tree_traversal: :postorder
expected={'files' => ['a0','a1','b0','b1','c0','c1','d0','d1'], 'value' => 30}
puts "files encountered: #{files}"
puts "#{config}"
puts "#{expected}"
puts "equal=#{config==expected}"
# default scheme
files=[]
config=YAML.ext_load_file 'd1.yaml', files: files
expected={'files' => ["d1", "d0", "a1", "a0", "b1", "b0", "c1", "c0"], 'value' => 30}
puts "files encountered: #{files}"
puts "#{config}"
puts "#{expected}"
puts "equal=#{config==expected}"

# simple base - derived
config=YAML.ext_load_file 'settings.yaml'
puts "config=YAML.ext_load_file 'settings.yaml'"
pp config
config=YAML.ext_load_file 'settings.yaml', tree_traversal: :postorder
puts "config=YAML.ext_load_file 'settings.yaml', tree_traversal: :postorder"
pp config

# file discovery


