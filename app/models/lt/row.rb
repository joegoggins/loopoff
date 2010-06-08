class Lt::Row
  attr_accessor :table, :name, :cells
  def initialize(table, name="")
    @table = table
    @name = name
    @cells = []
  end
end