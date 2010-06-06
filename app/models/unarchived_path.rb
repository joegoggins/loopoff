class UnarchivedPath < Dir
  attr_reader :db

  def initialize(db, absolute_path)
    @db = db
    super(absolute_path)
  end
  
  def name
    self.path.gsub(@db.path + '/','')
  end
  
  def to_param
    self.name
  end
end