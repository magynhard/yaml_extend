#!/usr/bin/env ruby

require '../lib/yaml_extend.rb'

# no automated check for now
config=YAML.ext_load_file 'd1.yaml', tree_traversal: :postorder
expected={'files' => ['a0','a1','b0','b1','c0','c1','d0','d1'], 'value' => 30}

puts "#{config}"
puts "#{expected}"
puts "equal=#{config==expected}"


