require 'spec_helper'
require 'json'

YAML_BINARY_PATH = './bin/yaml_extend'

RSpec.describe YAML,'CLI #ext_load_file' do
  context 'Test inheritance feature' do

    it 'respects multi-file inheritance precedence order' do
      yaml_path = 'spec/test_data/overwrite_multiple_files/child.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

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
      yaml_path = 'spec/test_data/array_merge_order/baby.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['pears'][0]).to eql('Ambrosia')
      expect(yaml_obj['pears'][1]).to eql('Bambinella')
      expect(yaml_obj['pears'][2]).to eql('Corella')
    end
    it 'merges array entries together' do
      yaml_path = 'spec/test_data/array_entry_merge/settings.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['blockX'][0]['playground']['macros']['M_BASE']).to eql('ja')
      expect(yaml_obj['blockX'][0]['playground']['macros']['M_REPLACE']).to eql('to_be_replaced')
      expect(yaml_obj['blockX'][1]['playground']['macros']['M_DERIVE']).to eql('ja')
      expect(yaml_obj['blockX'][1]['playground']['macros']['M_REPLACE']).to eql('replaced')
    end
    it 'extends with another yaml file' do
      yaml_path = 'spec/test_data/ext_load_file_02.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj).to include('first')
    end
    it 'extends with another yaml file from another directory' do
      yaml_path = 'spec/test_data/ext_load_file_04.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

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

      yaml_path = final_yaml_template_path
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['first']).to eql('foo')
      expect(yaml_obj['absolute']).to eql(true)
      expect(yaml_obj['third']).to eql('charm')
      FileUtils.rm_rf(final_tmp_dir)
     end
    it 'extends all countries (arrays) with qae' do
      yaml_path = 'spec/test_data/countries/sub/qa.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

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
      yaml_path = 'spec/test_data/countries/sub/qa.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj).not_to include('extends')
    end
    it 'overwrites existing values' do
      yaml_path = 'spec/test_data/overwrite/overwrite_person.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['data']['password']).to eql('ow1234')
      expect(yaml_obj['data']['email']).to eql('overwrite@mail.com')
      expect(yaml_obj['data']['phone']).to eql('0123456789')
      expect(yaml_obj['data']['first_name']).to eql('Odin')
    end
    it 'can extend and overwrite booleans' do
      yaml_path = 'spec/test_data/booleans/extended.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['data']['kappa']).to eql(false)
      expect(yaml_obj['data']['theta']).to eql(false)
      expect(yaml_obj['data']['delta']).to eql(true)
    end
    it 'can extend and overwrite string booleans' do
      yaml_path = 'spec/test_data/booleans/extended.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['string_data']['kappa']).to eql('false')
      expect(yaml_obj['string_data']['theta']).to eql('false')
      expect(yaml_obj['string_data']['delta']).to eql('true')
    end
    it 'can extend and overwrite nils' do
      yaml_path = 'spec/test_data/nil_values/extended.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['overwritten_nil']).to eql('string value')
      expect(yaml_obj['not_overwritten_string']).to eql('string value')
      expect(yaml_obj['overwritten_false']).to eql(nil)
      expect(yaml_obj['not_overwritten_true']).to eql(true)
    end
    it 'can extend and overwrite nils' do
      yaml_path = 'spec/test_data/nil_values/extended.yml'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

      expect(yaml_obj['overwritten_nil']).to eql('string value')
      expect(yaml_obj['not_overwritten_string']).to eql('string value')
      expect(yaml_obj['overwritten_false']).to eql(nil)
      expect(yaml_obj['not_overwritten_true']).to eql(true)
    end
  end
end

RSpec.describe YAML,'CLI #erb_in_yaml' do
  context 'Interprets ERB tags in yaml.erb files' do
    it "verifies ERB (String) in files ending with '.erb' or including '.erb.'' in file name" do
      yaml_path = 'spec/test_data/erb_in_yaml/config.yml.erb'
      result = `#{YAML_BINARY_PATH} #{yaml_path}`
      yaml_obj = YAML.load result

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