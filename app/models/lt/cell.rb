class Lt::Cell
  attr_accessor :row, :x, :y, :path
  def initialize(row, x, y,path)
    @row = row
    @x=x
    @y=y
    @path=path
  end
end