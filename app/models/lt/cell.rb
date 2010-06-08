class Lt::Cell
  attr_accessor :row, :x, :y, :identifier
  def initialize(row, x, y,identifier)
    @row = row
    @x=x
    @y=y
    @identifier=identifier
  end
  
  def to_param
    @identifier
  end
end