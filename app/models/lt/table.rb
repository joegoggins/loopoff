class Lt::Table
  attr_accessor :relative_path, :last_modified, :info, :rows, :parent

  # parent is the object that created the table
  def initialize(parent,relative_path="-") # NUANCE the "-" is instead of "." because I don't wnat the URL to encode it
    @parent = parent
    @relative_path = relative_path
    @info = ""
    @rows = []
    @last_modified = Time.now - 3.days
  end
end