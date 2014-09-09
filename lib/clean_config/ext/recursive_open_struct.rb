class RecursiveOpenStruct < OpenStruct
  def keys
    to_h.keys
  end

  def fetch(key, default = nil)
    to_h.fetch(key, default)
  end
end
