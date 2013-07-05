class Hash
  # Returns a new hash with +self+ and +other_hash+ merged recursively.
  #
  # h1 = { x: { y: [4,5,6] }, z: [7,8,9] }
  # h2 = { x: { y: [7,8,9] }, z: 'xyz' }
  #
  # h1.deep_merge(h2) #=> {x: {y: [7, 8, 9]}, z: "xyz"}
  # h2.deep_merge(h1) #=> {x: {y: [4, 5, 6]}, z: [7, 8, 9]}
  # h1.deep_merge(h2) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
  # #=> {:x=>{:y=>[4, 5, 6, 7, 8, 9]}, :z=>[7, 8, 9, "xyz"]}
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  # Same as +deep_merge+, but modifies +self+.
  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |key,value|
      tv = self[key]
      if tv.is_a?(Hash) && value.is_a?(Hash)
        self[key] = tv.deep_merge(value, &block)
      else
        self[key] = block && tv ? block.call(key, tv, value) : value
      end
    end
    self
  end
end