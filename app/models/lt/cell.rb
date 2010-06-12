class Lt::Cell
  attr_accessor :name, :size, :sha, :is_identical
  def initialize(hash={})
    hash.each_pair do |k,v|
      self.send("#{k}=",v)
    end
  end
end