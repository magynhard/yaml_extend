require "yaml_extend/version"

require 'yaml'
require 'deep_merge/rails_compat'

#
# Extending the YAML library to allow to inherit from another YAML file(s)
#

module YAML
  #
  # Extended variant of the #load_file method by providing the 
  # ability to inherit from other YAML file(s)
  #
  # @param yaml_path [String] the path to the yaml file to be loaded
  # @param inheritance_key [String] the key used in the yaml file to extend from another YAML file
  # @param extend_existing_arrays [Boolean] extend existing arrays instead of replacing them
  # @param config [Hash] a hash to be merged into the result, usually only recursivly called by the method itself
  #
  # @return [Hash] the resulting yaml config 
  #
  def self.ext_load_file(yaml_path, inheritance_key='extends', extend_existing_arrays=true, config = {})
    total_config ||= {}
    yaml_path = YAML.make_absolute_path yaml_path
    super_config = YAML.load_file(File.open(yaml_path))
    super_inheritance_files = super_config[inheritance_key]
    super_config.delete inheritance_key # we don't merge the super inheritance keys into the base yaml
    merged_config = config.clone.deeper_merge(super_config, extend_existing_arrays: extend_existing_arrays)
    if super_inheritance_files && super_inheritance_files != ''
      super_inheritance_files = [super_inheritance_files] unless super_inheritance_files.is_a? Array # we support strings as well as arrays of type string to extend from
      super_inheritance_files.each_with_index do |super_inheritance_file, index|
        super_config_path = File.dirname(yaml_path) + '/' + super_inheritance_file
        total_config = YAML.ext_load_file super_config_path, inheritance_key, extend_existing_arrays, total_config.deeper_merge(merged_config, extend_existing_arrays: extend_existing_arrays)
      end
      total_config
    else
      merged_config.delete(inheritance_key)
      merged_config
    end
  end

  private

  # some logic to ensure absolute file inheritance as well as 
  # relative file inheritance in yaml files  
  def self.make_absolute_path(file_path)
    private_class_method
    return file_path if YAML.absolute_path?(file_path) && File.exist?(file_path)
    base_path = File.dirname(caller_locations[1].path)
    return base_path + '/' + file_path if File.exist? base_path + '/' + file_path # relative path from yaml file
    return Dir.pwd + '/' + file_path if File.exist? Dir.pwd + '/' + file_path # relative path from project
    error_message = "Can not find absolute path of '#{file_path}'"
    unless YAML.absolute_path? file_path
      error_message += "\nAlso tried:\n- #{base_path + '/' + file_path}\n"\
                       "- #{Dir.pwd + '/' + file_path}\n"
    end
    raise error_message
  end

  def self.absolute_path?(path)
    private_class_method
    path.start_with?('/') || # unix like
      (path.length >= 3 && path[1] == ':') # ms windows
  end
end
