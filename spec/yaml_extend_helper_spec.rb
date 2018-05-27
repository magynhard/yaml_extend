require "spec_helper"

RSpec.describe YamlExtendHelper,'#decode_booleans / #encode_booleans' do
  context 'Encode and decode booleans' do

    yaml_obj = {
        tbool: true,
        fbool: false,
        nested: {
            fbool: false,
            tbool: true
        },
        array: [
            true,
            false,
            {
                fbool: false,
                array: [
                    true,
                    {
                        fbool: false
                    }
                ]
            }
        ]
    }

    it "can encode booleans" do
      yaml_obj = YamlExtendHelper.encode_booleans(yaml_obj)
      expect(yaml_obj[:tbool]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(yaml_obj[:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(yaml_obj[:nested][:tbool]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(yaml_obj[:nested][:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(yaml_obj[:array][0]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(yaml_obj[:array][1]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(yaml_obj[:array][2][:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(yaml_obj[:array][2][:array][0]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(yaml_obj[:array][2][:array][1][:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
    end
    it "can decode booleans" do
      yaml_obj = YamlExtendHelper.decode_booleans(yaml_obj)
      expect(yaml_obj[:tbool]).to eql(true)
      expect(yaml_obj[:fbool]).to eql(false)
      expect(yaml_obj[:nested][:tbool]).to eql(true)
      expect(yaml_obj[:nested][:fbool]).to eql(false)
      expect(yaml_obj[:array][0]).to eql(true)
      expect(yaml_obj[:array][1]).to eql(false)
      expect(yaml_obj[:array][2][:fbool]).to eql(false)
      expect(yaml_obj[:array][2][:array][0]).to eql(true)
      expect(yaml_obj[:array][2][:array][1][:fbool]).to eql(false)
    end
  end
end
