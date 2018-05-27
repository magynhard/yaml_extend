require "spec_helper"

RSpec.describe YamlExtendHelper,'#encode_booleans' do
  context 'Encoding booleans' do

    yaml_obj = {
        sbool: 'true',
        tbool: true,
        fbool: false,
        nested: {
            fbool: false,
            tbool: true,
            sbool: 'false'
        },
        array: [
            true,
            false,
            {
                fbool: false,
                array: [
                    true,
                    {
                        fbool: false,
                        sbool: 'true'
                    }
                ]
            },
            'false'
        ]
    }

    it "encodes booleans" do
      encoded = YamlExtendHelper.encode_booleans(yaml_obj)
      expect(encoded[:tbool]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(encoded[:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(encoded[:nested][:tbool]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(encoded[:nested][:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(encoded[:array][0]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(encoded[:array][1]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(encoded[:array][2][:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
      expect(encoded[:array][2][:array][0]).to eql(YamlExtendHelper::TRUE_CLASS_ENCODED)
      expect(encoded[:array][2][:array][1][:fbool]).to eql(YamlExtendHelper::FALSE_CLASS_ENCODED)
    end

    it "does not encode string booleans" do
      encoded = YamlExtendHelper.encode_booleans(yaml_obj)
      expect(encoded[:sbool]).to eql('true')
      expect(encoded[:nested][:sbool]).to eql('false')
      expect(encoded[:array][3]).to eql('false')
      expect(encoded[:array][2][:array][1][:sbool]).to eql('true')
    end
  end
end

RSpec.describe YamlExtendHelper,'#decode_booleans' do
  context 'Decoding booleans' do

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

    it "decodes booleans" do
      decoded = YamlExtendHelper.decode_booleans(yaml_obj)
      expect(decoded[:tbool]).to eql(true)
      expect(decoded[:fbool]).to eql(false)
      expect(decoded[:nested][:tbool]).to eql(true)
      expect(decoded[:nested][:fbool]).to eql(false)
      expect(decoded[:array][0]).to eql(true)
      expect(decoded[:array][1]).to eql(false)
      expect(decoded[:array][2][:fbool]).to eql(false)
      expect(decoded[:array][2][:array][0]).to eql(true)
      expect(decoded[:array][2][:array][1][:fbool]).to eql(false)
    end
  end
end
