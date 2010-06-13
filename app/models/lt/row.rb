class Lt::Row
  attr_accessor :name, :cells, :blob
  def initialize(hash={})
    hash.each_pair do |k,v|
      self.send("#{k}=",v)
    end
  end  
end