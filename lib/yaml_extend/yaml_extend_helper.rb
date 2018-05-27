
#
# This class includes a workaround patch, providing a solution of the unaccepted pull request
# 'false is not overriden by true if preserve_unmergeables'
# https://github.com/danielsdeleo/deep_merge/pull/28
#
# It ensures, that booleans can be merged correctly, by en- and decoding them to strings, before and after merging
# see #encode_boolens and #decode_booleans
#

class YamlExtendHelper

  TRUE_CLASS_ENCODED = '#={TrueClass}=#'
  FALSE_CLASS_ENCODED = '#={FalseClass}=#'

  def self.encode_booleans(hash)
    hash.each_with_object({}) do |(k,v),g|
      g[k] = if v.is_a? Hash
               YamlExtendHelper.encode_booleans(v)
             elsif v.is_a? Array
               v.each_with_index do |av, ai|
                  v[ai] = if av.is_a? Hash
                            YamlExtendHelper.encode_booleans(av)
                          elsif av.is_a? TrueClass
                            TRUE_CLASS_ENCODED
                          elsif av.is_a? FalseClass
                            FALSE_CLASS_ENCODED
                          else
                            av
                          end
               end
             elsif v.is_a? TrueClass
               TRUE_CLASS_ENCODED
             elsif v.is_a? FalseClass
               FALSE_CLASS_ENCODED
             else
               v
             end
    end
  end

  def self.decode_booleans(hash)
    hash.each_with_object({}) do |(k,v),g|
      g[k] = if v.is_a? Hash
               YamlExtendHelper.decode_booleans(v)
             elsif v.is_a? Array
               v.each_with_index do |av, ai|
                 v[ai] = if av.is_a? Hash
                           YamlExtendHelper.decode_booleans(av)
                         elsif av === TRUE_CLASS_ENCODED
                           true
                         elsif av === FALSE_CLASS_ENCODED
                           false
                         else
                           av
                         end
               end
             elsif v === TRUE_CLASS_ENCODED
               true
             elsif v === FALSE_CLASS_ENCODED
               false
             else
               v
             end
    end
  end

end