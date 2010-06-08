class UnarchivedPath < Dir
  attr_reader :db, :repo

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
  
  def new_blob_ids
    self.distinct_blob_ids - self.db.repo.all_distinct_blobs.map(&:id)
  end

  def new_blobs
    self.repo.tree.blobs.select {|x| self.new_blob_ids.include?(x.id)}
  end
  
  def identical_blobs
    self.repo.tree.blobs.select {|x| self.idential_blob_ids.include?(x.id)}
  end
  
  def idential_blob_ids
    self.distinct_blob_ids & self.db.repo.all_distinct_blobs.map(&:id)
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