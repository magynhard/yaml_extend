require "spec_helper"

RSpec.describe YamlExtend do
  it "has a version number" do
    expect(YamlExtend::VERSION).not_to be nil
  end
end

RSpec.describe YAML,'#ext_load_file' do
  context 'Test inheritance feature' do

    it 'respects multi-file inheritance precedence order' do
      yaml_obj = YAML.ext_load_file 'test_data/overwrite_multiple_files/child.yml'

      expect(yaml_obj['own_parent_L1_A']).to eql('parent L1 A value')
      expect(yaml_obj['overwritten_until_L1_B']).to eql('parent L1 B value')
      expect(yaml_obj['own_parent_L1_B']).to eql('parent L1 B value')
      expect(yaml_obj['overwritten_until_L2_A']).to eql('parent L2 A value')
      expect(yaml_obj['own_parent_L2_A']).to eql('parent L2 A value')
      expect(yaml_obj['overwritten_until_L2_B']).to eql('parent L2 B value')
      expect(yaml_obj['own_parent_L2_B']).to eql('parent L2 B value')
      expect(yaml_obj['overwritten_until_L2_C']).to eql('parent L2 C value')
      expect(yaml_obj['own_parent_L2_C']).to eql('parent L2 C value')
      expect(yaml_obj['overwritten_until_child']).to eql('child value')
      expect(yaml_obj['own_child']).to eql('child value')
    end
    it 'appends new Array entries at the end from parent to children' do
      yaml_obj = YAML.ext_load_file 'test_data/array_merge_order/baby.yml'
      expect(yaml_obj['pears'][0]).to eql('Ambrosia')
      expect(yaml_obj['pears'][1]).to eql('Bambinella')
      expect(yaml_obj['pears'][2]).to eql('Corella')
    end
    it 'merges array entries together' do
      yaml_obj = YAML.ext_load_file 'test_data/array_entry_merge/settings.yml'
      expect(yaml_obj['blockX'][0]['playground']['macros']['M_BASE']).to eql('ja')
      expect(yaml_obj['blockX'][0]['playground']['macros']['M_REPLACE']).to eql('to_be_replaced')
      expect(yaml_obj['blockX'][1]['playground']['macros']['M_DERIVE']).to eql('ja')
      expect(yaml_obj['blockX'][1]['playground']['macros']['M_REPLACE']).to eql('replaced')
    end
    it 'extends with another yaml file' do
      yaml_obj = YAML.ext_load_file 'test_data/ext_load_file_02.yml'
      expect(yaml_obj).to include('first')
    end
    it 'extends with another yaml file from another directory' do
      yaml_obj = YAML.ext_load_file 'test_data/ext_load_file_04.yml'
      expect(yaml_obj).to include('first')
    end
    it 'extends with another yaml from another absolute directory' do
      source_tmp_file_path = File.expand_path 'spec/test_data/ext_load_file_absolute_02.yml'
      source_tmp_file_content = File.read(source_tmp_file_path)
      source_tmp_file_name = File.basename source_tmp_file_path
      final_tmp_dir = Dir.tmpdir + '/rspec/'
      dest_tmp_file_path = final_tmp_dir + source_tmp_file_name
      FileUtils.mkdir_p final_tmp_dir
      FileUtils.cp_r source_tmp_file_path, dest_tmp_file_path
      # create platform specific yaml file by template
      is_windows_platform = (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
      if is_windows_platform
        expect(dest_tmp_file_path[1]).to eql(':')
      else
        expect(dest_tmp_file_path).to start_with('/')
      end
      yaml_template = File.read('spec/test_data/ext_load_file_absolute_01.yml.tmpl')
      final_yaml_template_content = yaml_template.gsub('{{absolute_template_path}}', dest_tmp_file_path)
      final_yaml_template_path = final_tmp_dir + 'ext_load_file_absolute_01.yml'
      File.write(final_yaml_template_path, final_yaml_template_content)
      FileUtils.cp_r('spec/test_data/ext_load_file_absolute_03.yml', final_tmp_dir)
      yaml_obj = YAML.ext_load_file final_yaml_template_path
      expect(yaml_obj['first']).to eql('foo')
      expect(yaml_obj['absolute']).to eql(true)
      expect(yaml_obj['third']).to eql('charm')
      FileUtils.rm_rf(final_tmp_dir)
     end
    it 'extends with another yaml file by using another extend key' do
      yaml_obj = YAML.ext_load_file 'test_data/other_key.yml', 'inherits_from'
      expect(yaml_obj).to include('first')
    end
    it 'extends with another yaml file by using another extend key and by three levels' do
      yaml_obj = YAML.ext_load_file 'test_data/3rd.yml', 'super'
      expect(yaml_obj).to include('first')
    end
    it 'extends by two another yaml files by using another extend key' do
      yaml_obj = YAML.ext_load_file 'test_data/food.yml', 'ext'
      expect(yaml_obj).to include('lemonade')
      expect(yaml_obj).to include('apples')
    end
    it 'extends all countries (arrays) with qae' do
      yaml_obj = YAML.ext_load_file 'test_data/countries/sub/qa.yml'
      expect(yaml_obj).to include('countries')
      expect(yaml_obj['countries']).to include('qa')
      expect(yaml_obj['countries']).to include('global')
      expect(yaml_obj['countries']).to include('de')
      expect(yaml_obj['countries']).to include('at')
      expect(yaml_obj['countries']).to include('ch')
      expect(yaml_obj['countries']).to include('fr')
      expect(yaml_obj['countries']).to include('nl')
      expect(yaml_obj['countries']).to include('be')
    end
    it 'there is no extend key in the final file' do
      yaml_obj = YAML.ext_load_file 'test_data/countries/sub/qa.yml'
      expect(yaml_obj).not_to include('extends')
    end
    it 'there is no specified extend key in the final file' do
      yaml_obj = YAML.ext_load_file 'test_data/countries/sub/qa.yml','inherits_from'
      expect(yaml_obj).not_to include('inherits_from')
    end
    it 'overwrites existing values' do
      yaml_obj = YAML.ext_load_file 'test_data/overwrite/overwrite_person.yml'
      expect(yaml_obj['data']['password']).to eql('ow1234')
      expect(yaml_obj['data']['email']).to eql('overwrite@mail.com')
      expect(yaml_obj['data']['phone']).to eql('0123456789')
      expect(yaml_obj['data']['first_name']).to eql('Odin')
    end
    it 'extends from custom nested (Array) key' do
      yaml_obj = YAML.ext_load_file 'test_data/yaml_value_by_key/config.yml', ['options','inherits_from']
      expect(yaml_obj['super']).to eql(true)
    end
    it 'has no custom extension key in the final merged yaml included (String)' do
      yaml_obj = YAML.ext_load_file 'test_data/other_key.yml', 'inherits_from'
      expect(yaml_obj['inherits_from']).to eql(nil)
    end
    it 'has no custom extension key in the final merged yaml included (Array)' do
      yaml_obj = YAML.ext_load_file 'test_data/yaml_value_by_key/config.yml', ['options','inherits_from']
      expect(yaml_obj['options']['inherits_from']).to eql(nil)
    end
    it 'can extend and overwrite booleans' do
      yaml_obj = YAML.ext_load_file 'test_data/booleans/extended.yml'
      expect(yaml_obj['data']['kappa']).to eql(false)
      expect(yaml_obj['data']['theta']).to eql(false)
      expect(yaml_obj['data']['delta']).to eql(true)
    end
    it 'can extend and overwrite string booleans' do
      yaml_obj = YAML.ext_load_file 'test_data/booleans/extended.yml'
      expect(yaml_obj['string_data']['kappa']).to eql('false')
      expect(yaml_obj['string_data']['theta']).to eql('false')
      expect(yaml_obj['string_data']['delta']).to eql('true')
    end
    it 'can extend and overwrite nils' do
      yaml_obj = YAML.ext_load_file 'test_data/nil_values/extended.yml'
      expect(yaml_obj['overwritten_nil']).to eql('string value')
      expect(yaml_obj['not_overwritten_string']).to eql('string value')
      expect(yaml_obj['overwritten_false']).to eql(nil)
      expect(yaml_obj['not_overwritten_true']).to eql(true)
    end
    it 'can extend and overwrite nils' do
      yaml_obj = YAML.ext_load_file 'test_data/nil_values/extended.yml'
      expect(yaml_obj['overwritten_nil']).to eql('string value')
      expect(yaml_obj['not_overwritten_string']).to eql('string value')
      expect(yaml_obj['overwritten_false']).to eql(nil)
      expect(yaml_obj['not_overwritten_true']).to eql(true)
    end
  end
  context 'Test options' do
    # parameter changed from Boolean to Hash in 1.0.2
    it 'merges arrays if parameter true (backward compatibility)' do
      yaml_obj = YAML.ext_load_file 'test_data/option_extend_existing_array/child.yml', nil, true
      expect(yaml_obj['fruits']).to include('Banana','Orange','Grapefruit')
    end
    # parameter changed from Boolean to Hash in 1.0.2
    it 'does not merge arrays if parameter false (backward compatibility)' do
      yaml_obj = YAML.ext_load_file 'test_data/option_extend_existing_array/child.yml', nil, false
      expect(yaml_obj['fruits']).to include('Grapefruit')
      expect(yaml_obj['fruits']).not_to include('Banana','Orange')
    end
    # parameter changed from Boolean to Hash in 1.0.2
    it 'does merge arrays if parameter true in options hash' do
      yaml_obj = YAML.ext_load_file 'test_data/option_extend_existing_array/child.yml', nil, { extend_existing_arrays: true }
      expect(yaml_obj['fruits']).to include('Banana','Orange','Grapefruit')
    end
    # parameter changed from Boolean to Hash in 1.0.2
    it 'does not merge arrays if parameter false in options hash' do
      yaml_obj = YAML.ext_load_file 'test_data/option_extend_existing_array/child.yml', nil, { extend_existing_arrays: false }
      expect(yaml_obj['fruits']).to include('Grapefruit')
      expect(yaml_obj['fruits']).not_to include('Banana','Orange')
    end
    it 'does merge hash arrays if parameter true in options hash' do
     yaml_obj = YAML.ext_load_file 'spec/test_data/merge_hash_array_overwrite/child.yml', nil, { merge_hash_arrays: true }
      trait_values = yaml_obj['dog'][0]['traits'].map do |trait|
        trait['name']
      end
      expect(trait_values).to match_array(['friendly', 'happy', 'smart', 'strong'])
    end
    it 'does not delete inheritance key if option is set to false' do
      yaml_obj = YAML.ext_load_file 'test_data/option_extend_existing_array/child.yml', nil, { preserve_inheritance_key: true }
      expect(yaml_obj).to include('extends')
    end
    it 'deletes inheritance key if option is set to true' do
      yaml_obj = YAML.ext_load_file 'test_data/option_extend_existing_array/child.yml', nil, { preserve_inheritance_key: false }
      expect(yaml_obj).not_to include('extends')
    end
  end
end

RSpec.describe YAML,'#inheritance_yaml_by_key' do
  context 'Check values from yaml extraction' do

    config = YAML.ext_load_file 'test_data/yaml_value_by_key/config.yml'

    it 'can extract a value from top level by String' do
      value = YAML.send :yaml_value_by_key, 'not_nested', config
      expect(value).to eql('top_level')
    end
    it 'can extract a value from top level by Array' do
      value = YAML.send :yaml_value_by_key, ['not_nested'], config
      expect(value).to eql('top_level')
    end
    it 'can extract a value from second level by Array' do
      value = YAML.send :yaml_value_by_key, ['nest','nested_key'], config
      expect(value).to eql('nested_value')
    end
    it 'can extract a value from deep level by Array' do
      value = YAML.send :yaml_value_by_key, ['nest2','sub','sub_sub','very_nested_key'], config
      expect(value).to eql('very_nested_value')
    end
    it 'can not extract value from an inexisting, nested key deep leveled in Array' do
      value = YAML.send :yaml_value_by_key, ['nest7','sub4','sub_sub3','very_nested_key1'], config
      expect(value).to eql(nil)
    end
    it 'can not read from key of type integer' do
      expect { YAML.send :yaml_value_by_key, 123, config }.to raise_error(InvalidKeyTypeError)
    end
    it 'can not read from key of type integer in Array' do
      expect { YAML.send :yaml_value_by_key, [1], config }.to raise_error(InvalidKeyTypeError)
    end
    it 'can not read from key of type integer in nested Array' do
      expect { YAML.send :yaml_value_by_key, ["nest",1], config }.to raise_error(InvalidKeyTypeError)
    end
  end
end

RSpec.describe YAML,'#delete_yaml_key' do
  context 'Verify correct deletion of yaml key' do
    it 'deletes a key (String)' do
      yaml_obj = YAML.ext_load_file 'test_data/yaml_value_by_key/config.yml', ['options','inherits_from']
      value = YAML.send :delete_yaml_key, 'nest2', yaml_obj
      expect(yaml_obj['nest2']).to eql(nil)
    end
    it 'deletes a nested key (Array)' do
      yaml_obj = YAML.ext_load_file 'test_data/yaml_value_by_key/config.yml', ['options','inherits_from']
      value = YAML.send :delete_yaml_key, ['nest','nested_key'], yaml_obj
      expect(yaml_obj['nest']['nested_key']).to eql(nil)
      expect(yaml_obj['nest']).not_to eql(nil)
    end
    it 'does not delete other keys on the level of a nested key (Array)' do
      yaml_obj = YAML.ext_load_file 'test_data/yaml_value_by_key/config.yml', ['options','inherits_from']
      expect(yaml_obj['options']['another_option']).to eql('OPT')
    end
  end
end

RSpec.describe YAML,'#ext_load_key=' do
  context 'Set the inheritance key globally' do
    it 'check if key persists through several loadings' do
      YAML.ext_load_key = ['options','inherits_from']
      yaml_obj = YAML.ext_load_file 'test_data/load_ext_key/config1.yml'
      expect(yaml_obj['super']).to eql('super1')
      yaml_obj = YAML.ext_load_file 'test_data/load_ext_key/config2.yml'
      expect(yaml_obj['super']).to eql('super2')
    end
    it 'can reset the load key by reset method' do
      YAML.ext_load_key = ['options','inherits_from']
      yaml_obj = YAML.ext_load_file 'test_data/load_ext_key/config1.yml'
      expect(yaml_obj['super']).to eql('super1')
      YAML.reset_load_key
      yaml_obj = YAML.ext_load_file 'test_data/load_ext_key/config2.yml'
      expect(yaml_obj['super']).to eql(nil)
    end
    it "can reset the load key by explicit key value 'nil'" do
      YAML.ext_load_key = ['options','inherits_from']
      yaml_obj = YAML.ext_load_file 'test_data/load_ext_key/config1.yml'
      expect(yaml_obj['super']).to eql('super1')
      YAML.ext_load_key = nil
      yaml_obj = YAML.ext_load_file 'test_data/load_ext_key/config2.yml'
      expect(yaml_obj['super']).to eql(nil)
    end
    # reset key
    YAML.reset_load_key
  end
end

RSpec.describe YAML,'#erb_in_yaml' do
  context 'Interprets ERB tags in yaml.erb files' do
    it "verifies ERB (String) in files ending with '.erb' or including '.erb.'' in file name" do
      yaml_obj = YAML.ext_load_file 'test_data/erb_in_yaml/config.yml.erb'
      expect(yaml_obj['erb']).to eql('FooBar')
      expect(yaml_obj['super_erb']).to eql('SuperFoo')
      expect(yaml_obj['different_file_extension_order']).to eql(true)
      expect(yaml_obj['yaml_erb']).to eql('YamlERB')
      expect(yaml_obj['erbse1']).to eql("<%= 'DoNot' + 'Render1' %>")
      expect(yaml_obj['erbse2']).to eql("<%= 'DoNot' + 'Render2' %>")
      expect(yaml_obj['herb']).to eql("<%= 'DoNot' + 'Render3' %>")
      expect(yaml_obj['herbs']).to eql("<%= 'DoNot' + 'Render4' %>")
    end
  end
end
