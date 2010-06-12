class Lt::Cell
  attr_accessor :name, :size, :sha, :is_identical
  def initialize(hash={})
    hash.each_pair do |k,v|
      self.send("#{k}=",v)
    end
  end
  
  def basename
    File.basename(self.name)
  end
  alias_method :to_param, :basename
  
  
  def data
    File.read(self.name)
  end
end