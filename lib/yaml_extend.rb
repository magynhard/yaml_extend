require 'yaml_extend/version'

require 'yaml'
require 'deep_merge/rails_compat'

require_relative 'custom_errors/invalid_key_type_error'

#
# Extending the YAML library to allow to inherit from another YAML file(s)
#

module YAML
  # default path in the yaml file where the files to inherit from are defined
  DEFAULT_INHERITANCE_KEY = 'extends'
  @@ext_load_key = nil

  DEEP_MERGE_OPTIONS = [
      :preserve_unmergeables,
      :knockout_prefix,
      :overwrite_arrays,
      :sort_merged_arrays,
      :unpack_arrays,
      :merge_hash_arrays,
      :extend_existing_arrays,
      :merge_nil_values,
      :merge_debug,
  ]

  #
  # Set a custom inheritance key globally once.
  # So you don't need to specify it on every call of ext_load_file()
  #
  # @param key [String|Array<String>|nil] the key in the yaml file, containing the file strings to extend from. Set nil or call #reset_load_key to reset the key.
  def self.ext_load_key=(key)
    if key.is_a?(String) || key.is_a?(Array) || key.nil?
      @@ext_load_key = key
    else
      raise "Parameter 'key' must be of type String or Array<String> or nil"
    end
  end

  #
  # Reset the ext_load_key and use the default settings
  #
  def self.reset_load_key()
    @@ext_load_key = nil
  end

  #
  # Extended variant of the YAML.load_file method by providing the
  # ability to inherit from other YAML file(s)
  #
  # @param [String] yaml_path the path to the yaml file to be loaded
  # @param [String|Array] inheritance_key The key used in the yaml file to extend from another YAML file. Use an Array if you want to use a tree structure key like "options.extends" => ['options','extends']
  # @param [Hash] options to pass, including deep_merge options as well as
  # @option options [Boolean] :preserve_inheritance_key Preserve inheritance key(s) from resulting yaml, does most time not make sense especially in multiple inheritance - DEFAULT: false
  #
  # deep merge options that can be passed by - but the defaults differ from original
  # https://github.com/danielsdeleo/deep_merge#options
  #
  # @option options [Boolean] :preserve_unmergeables Set to true to skip any unmergeable elements from source - DEFAULT: false
  # @option options [String] :knockout_prefix Set to string value to signify prefix which deletes elements from existing element - DEFAULT: nil
  # @option options [Boolean] :overwrite_arrays Set to true if you want to avoid merging arrays - DEFAULT: false
  # @option options [Boolean] :sort_merged_arrays Set to true to sort all arrays that are merged together - DEFAULT: false
  # @option options [String] :unpack_arrays Set to string value to run "Array::join" then "String::split" against all arrays - DEFAULT: nil
  # @option options [Boolean] :merge_hash_arrays Set to true to merge hashes within arrays - DEFAULT: false
  # @option options [Boolean] :extend_existing_arrays Set to true to extend existing arrays, instead of overwriting them - DEFAULT: true
  # @option options [Boolean] :merge_nil_values Set to true to merge nil hash values, overwriting a possibly non-nil value - DEFAULT: false
  # @option options [Boolean] :merge_debug Set to true to get console output of merge process for debugging - DEFAULT: false
  #
  # @param  [Boolean] options Fallback for backward compatiblity: extend existing arrays instead of replacing them (deep_merge)
  # @return [Hash] the resulting yaml config 
  #
  def self.ext_load_file(yaml_path, inheritance_key = nil, options = {})
    YAML.ext_load_file_recursive(yaml_path, inheritance_key, options, {})
  end

  private

  #
  # @param config [Hash] a hash to be merged into the result, usually only recursivly called by the method itself
  #
  def self.ext_load_file_recursive(yaml_path, inheritance_key, options = {}, config)
    # backward compatibility to 1.0.1
    if options == true || options == false
      options = {extend_existing_arrays: options}
    end
    default_options = {
        preserve_inheritance_key: false,
        preserve_unmergeables: false,
        knockout_prefix: nil,
        overwrite_arrays: false,
        sort_merged_arrays: false,
        unpack_arrays: nil,
        merge_hash_arrays: false,
        extend_existing_arrays: true,
        merge_nil_values: false,
        merge_debug: false,
    }
    options = default_options.merge options
    private_class_method
    if inheritance_key.nil?
      inheritance_key = @@ext_load_key || DEFAULT_INHERITANCE_KEY
    end
    total_config = config.clone

    yaml_path = YAML.make_absolute_path yaml_path

    super_config =
      if yaml_path.match(/(\.erb\.|\.erb$)/)
        YAML.load(ERB.new(File.read(yaml_path)).result)
      else
        YAML.load_file(File.open(yaml_path))
      end

    super_inheritance_files = yaml_value_by_key inheritance_key, super_config
    unless options[:preserve_inheritance_key]
      delete_yaml_key inheritance_key, super_config # we don't merge the super inheritance keys into the base yaml
    end

    if super_inheritance_files && super_inheritance_files != ''
      super_inheritance_files = [super_inheritance_files] unless super_inheritance_files.is_a? Array # we support strings as well as arrays of type string to extend from
      super_inheritance_files.each_with_index do |super_inheritance_file, index|
        # Extend a YAML path in an absolute directory
        if YAML.absolute_path?(super_inheritance_file)
          super_config_path = YAML.make_absolute_path(super_inheritance_file)
          # Extend a YAML path in a relative directory
        else
          super_config_path = File.dirname(yaml_path) + '/' + super_inheritance_file
        end
        total_config = YAML.ext_load_file_recursive(super_config_path, inheritance_key, options, total_config)
      end
    end
    deep_merge_options = options.select { |k, v| DEEP_MERGE_OPTIONS.include? k }
    total_config.deeper_merge!(super_config, deep_merge_options)
  end

  # some logic to ensure absolute file inheritance as well as 
  # relative file inheritance in yaml files  
  def self.make_absolute_path(file_path)
    private_class_method
    return file_path if YAML.absolute_path?(file_path) && File.exist?(file_path)
    # caller_locations returns the current execution stack
    #   [0] is the call from ext_load_file_recursive,
    #   [1] is inside ext_load_file,
    #   [2] is the exteranl caller of YAML.ext_load_file
    base_path = File.dirname(caller_locations[2].path)
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

  # Return the value of the corresponding key
  # @param key [String|Array]
  def self.yaml_value_by_key(key, config)
    return config[key] if key.is_a? String
    if valid_key_type? key
      cfg_copy = config.clone
      key.each do |key|
        if cfg_copy.nil?
          return
        elsif valid_key_type? key
          cfg_copy = cfg_copy[key]
        end
      end
      cfg_copy
    end
  end

  def self.valid_key_type?(key)
    key.is_a?(Array) || key.is_a?(String) ||
        raise(InvalidKeyTypeError, "Invalid key of type '#{key.class.name}'. Valid types are String and Array.")
  end

  def self.delete_yaml_key(key, config)
    return config.delete(key) if key.is_a? String
    cfg_ref = config
    last_ref = nil
    key.each do |key|
      if valid_key_type?(key) && !cfg_ref[key].nil?
        last_ref = cfg_ref
        cfg_ref = cfg_ref[key] unless cfg_ref.nil?
      end
    end
    last_ref.delete key.last unless last_ref.nil?
  end

end
