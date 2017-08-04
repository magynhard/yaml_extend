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
  end
end
