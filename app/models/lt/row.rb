class Lt::Row
  attr_accessor :name, :cells, :blob
  def initialize(hash={})
    hash.each_pair do |k,v|
      self.send("#{k}=",v)
    end
  end
  
  def cell(index)
    if cells.kind_of? Array
      self.cells[index]
    else
      nil
    end
  end  
end