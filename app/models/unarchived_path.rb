class UnarchivedPath < Dir
  attr_reader :db, :repo

  def initialize(db, absolute_path)
    @db = db
    super(absolute_path)
  end
  
  def name
    self.path.gsub(@db.path + '/','')
  end
  alias_method :relative_path, :name
  alias_method :to_param, :name
  
  
  def to_param
    self.name
  end
  
  def new_blob_ids
    self.distinct_blob_ids - self.db.repo.distinct_blobs.map(&:id)
  end

  def new_blobs
    self.repo.tree.blobs.select {|x| self.new_blob_ids.include?(x.id)}
  end
  
  def identical_blobs
    self.repo.tree.blobs.select {|x| self.idential_blob_ids.include?(x.id)}
  end
  
  def idential_blob_ids
    self.distinct_blob_ids & self.db.repo.distinct_blobs.map(&:id)
  end
  
  # Requires you to manually create the repo for now, Grit and Gash
  # were being dumb, raises
  #   Grit::InvalidGitRepositoryError => e
  def repo
    @repo ||= Grit::Repo.new(self.path)
  end
  
  # WARNING DUPLICATION: from repo.rb
  def distinct_blobs
    if @distinct_blobs.blank?
      distinct_blob_ids = []
      @distinct_blobs = []
      self.repo.commits.each do |c|
        c.tree.blobs.each do |b|
          unless distinct_blob_ids.include?(b.id)            
            @distinct_blobs << b
            distinct_blob_ids << b.id
          end
        end
      end      
    end
    @distinct_blobs
  end
  
  def distinct_blob_ids
    self.distinct_blobs.map(&:id)
  end
  
  
  def table
    #    Db.aggregated_blobs(self.distinct_blobs)
    #    c1
    #     001_1
    #     001_2
    #     001_3
    #    c2
    #     001_2
    #    c3
    #     001_1
    #     002_2.WAV
    #     002_3.WAV
    #
    # @table = Lt::Table.new
    # r = Lt::Row.new('001')
    # r.cells << Lt::Cell.new(0,0,"001_1.WAV")
    # r.cells << Lt::Cell.new(0,1,"001_2.WAV")
    # r.cells << Lt::Cell.new(0,2,"001_3.WAV")
    # @table.rows << r
    # 
    # r = Lt::Row.new('001')
    # r.cells << Lt::Cell.new(1,0,"001_2.WAV")
    # @table.rows << r
    # 
    # r = Lt::Row.new('001')
    # r.cells << Lt::Cell.new(1,0,"001_1.WAV")
    # @table.rows << r
    # r = Lt::Row.new('002')
    # r.cells << Lt::Cell.new(2,0,"002_2.WAV")
    # r.cells << Lt::Cell.new(2,1,"002_3.WAV")
    # @table.rows << r
    @table = Lt::Table.new(self, self.relative_path)
    self.repo.commits.each_with_index do |c,commit_index|
      @row = Lt::Row.new(@table)
      c.tree.blobs.group_by {|b| b.name.split('_').first}.each_with_index do |tuple,blob_index|
        @row.name = tuple.first
        #["001", [#<Grit::Blob "48b4a7f76b059fe8ec04389ff90ca303b6180265">, #<Grit::Blob "3135902f33f339b671e9d2604a3c90f12280409b">, #<Grit::Blob "bc22f5ca84204a9b53ad3f14586fad23a72ed6d4">]]        tuple
        tuple.last.each_with_index do |blob,cell_index|
          @cell = Lt::Cell.new(@row, blob_index,cell_index,blob.name)
          @row.cells << @cell.dup          
        end
        @table.rows << @row.dup
        #prefix, middle, extension = b.name.match(/(.+)_(.+)\.(.+)/).to_a[1..-1] 
      end 
    end
    return @table
  end
  
  def loopoff_files
    Db.loopoff_files(self.entries.map {|x| File.join(self.path,x)})
  end
  
  
  # NOT WORKING: hell with this: no writes from ruby git, seems tricky/unstable
  # def add_all
  #     self.loopoff_files.each do |f|
  #       self.repo.index.add(File.basename(f),File.read(f))  
  #     end
  #     self.repo.index.commit("adding all")
  #   end
end