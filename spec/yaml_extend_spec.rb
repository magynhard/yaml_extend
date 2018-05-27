require "spec_helper"

RSpec.describe YamlExtend do
  it "has a version number" do
    expect(YamlExtend::VERSION).not_to be nil
  end
end

RSpec.describe YAML,'#ext_load_file' do
  context 'Test inheritance feature' do
    it 'extends with another yaml file' do
      yaml_obj = YAML.ext_load_file 'test_data/ext_load_file_02.yml'
      expect(yaml_obj).to include('first')
    end
    it 'extends with another yaml file from another directory' do
      yaml_obj = YAML.ext_load_file 'test_data/ext_load_file_04.yml'
      expect(yaml_obj).to include('first')
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