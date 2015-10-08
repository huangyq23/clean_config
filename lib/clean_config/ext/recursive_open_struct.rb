# Monkeypatching RecursiveOpenStruct to respond to common Hash methods
class RecursiveOpenStruct < OpenStruct
  # Returns array with keys from the RecursiveOpenStruct
  # @return [Array] keys
  def keys
    to_h.keys
  end

  # Returns value for given key
  # @param [Object] key key to retrieve value
  # @param [Object] default value to return if key is not found
  # @return [Object] value associated with given key
  def fetch(key, default = nil)
    to_h.fetch(key, default)
  end
end
