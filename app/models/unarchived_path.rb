class UnarchivedPath < Dir
  # INNER HELPER CLASS
  class MyFile
    attr_accessor :name, :size, :sha
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
  
  
  
  attr_reader :db, :repo, :my_files
  def initialize(db, absolute_path)
    @db = db
    super(absolute_path)    
  end
  
  def my_files
    if @my_files.blank?
      @my_files = []
      self.loopoff_files.each do |f|
        @my_files << MyFile.new(:name => f,
          :size => File.size(f),
          :sha => self.file_ids_hash[File.basename(f)] #Grit::GitRuby::Internal::LooseStorage.calculate_sha(File.read(f),'blob')
        )
      end
    end
    @my_files    
  end
  

  def my_aggregated_files
    self.my_aggregated_file_hash.to_a
  end
  
  def my_aggregated_file_hash
    if @my_aggregated_file_hash
      @my_aggregated_file_hash
    else
      # yields elements like ["007", ["007_2.WAV", "007_3.WAV"]]
      @my_aggregated_file_hash = self.my_files.group_by do |my_file|
        my_file.basename.split('_').first
      end
         #{|x| File.basename(x.name)}.group_by {|x| x.split('_').first}.sort
      
      # insert nils to make matrix solid, like ["007", [nil, "007_2.WAV", "007_3.WAV"]]
      @my_aggregated_file_hash.map do |x| 
        if x.last.length != 3
          modded_3_tuple = [nil,nil,nil]
          x.last.each_with_index do |my_file,index|
            f_number = my_file.basename.split('_').last.gsub(/\.WAV/,'').to_i # the 2 or 3 part minus the .WAV
            modded_3_tuple[f_number-1] = my_file            
          end
          x[1]=modded_3_tuple
          x
        else 
          x
        end
      end
    end
  end
  
  def my_file_hash
    if @my_file_hash.blank?
      @my_file_hash = {}
      self.my_files.each do |f|
        @my_file_hash[File.basename(f.name)] = f
      end
    end
    @my_file_hash
  end
  
  # returns the file name on
  def cell(x,y)
    self.my_aggregated_files[x.to_i][1][y.to_i]
  end
  
  def name
    self.path.gsub(@db.path + '/','')
  end
  alias_method :relative_path, :name
  alias_method :to_param, :name
  
  
  def to_param
    self.name
  end
  
  def repo
    @repo ||= Grit::Repo.new(self.path)
  end
  
  # p = Db[:rc50].unarchived_paths(/07/)[0]
  # p.file_ids_hash
  # "006_1.WAV"=>"810c66e795db7a9cbfea9735f11336629ab6db30", "011_3.WAV"=>"f668d505e9500fb580d9ef89e3db094d9984b683", "030_1.WAV"=>"9749e0bac6b3ca57faab1848475906e99ee3b699"}
  def file_ids_hash
    if @file_ids_hash.blank?
      # load the file sha's from cache if possible
      cache_file = File.join(self.path,'.loopoff')
      if File.exists?(cache_file)
         @file_ids_hash = YAML.load(File.read(cache_file))
      else
        # build it
        @file_ids_hash = {}
        self.loopoff_files.each do |f|
          @file_ids_hash[File.basename(f)] = Grit::GitRuby::Internal::LooseStorage.calculate_sha(File.read(f),'blob')
        end
        # write the cache
        File.open(cache_file,'w') do |f|
          f.puts YAML.dump(@file_ids_hash)          
        end
      end           
    end
    @file_ids_hash
  end
    
  def my_new_files
    self.my_files.select {|x| self.db.repo.distinct_blobs.map(&:id).include?(x.sha)}
  end
  # def new_blob_ids
  #   self.distinct_blob_ids - self.db.repo.distinct_blobs.map(&:id)
  # end
  # 
  # # FIX: p = Db[:rc50].unarchived_paths(/0529/)[0]
  # # p.distinct_blobs
  # # => ["76c62a5d3ef0e37802c3632a15219e580eab405b", "4ce831386425818744af9864778ec0c37d339555", "8c9906cec4557bb7cb90a65ade29a9e0bf6fddea", "1610294c33bd526fb236d9917bb57c74d7207f2c", "1175d36089d079fd49c18c808e3d138d387cba4a", "5681bc6e4081add10cb817b06e062586ffe54a4a", "8bc91277112d56eb6874caf3081387ad2e647fd5", "73d90ed25e75c123f50e4a272a4b2d3c87773347", "a5fe15a204c59c4a2f46f5c1c614a64f2a980e9c", "1e45a3b2bfb8c43d80cd656781d920cae74e8bc2", "56443ed770a6f480f9ffd157036deda5ec6b9306", "8417d133f1a2b12f4df345c8f007188c1c0104ca", "1d29f62712c2ba72702c497d12c2e574e68a7ee3", "feaeb9c3aad896a74be472118c5a1c6d6ad5e436", "56ceabd8d37a79b1f72acb013058508a662cdc0a"]
  # def new_blobs
  #   #self.repo.tree.blobs.select {|x| self.new_blob_ids.include?(x.id)}
  #   #Grit::GitRuby::Internal::LooseStorage.calculate_sha(File.read(f),'blob') instead
  # end
  # 
  # def identical_blobs
  #   self.repo.tree.blobs.select {|x| self.idential_blob_ids.include?(x.id)}
  # end
  # 
  # def idential_blob_ids
  #   self.distinct_blob_ids & self.db.repo.distinct_blobs.map(&:id)
  # end
  
  # Requires you to manually create the repo for now, Grit and Gash
  # were being dumb, raises
  #   Grit::InvalidGitRepositoryError => e
  
  # # WARNING DUPLICATION: from repo.rb
  # def distinct_blobs
  #   if @distinct_blobs.blank?
  #     @distinct_blobs = []
  #     self.loopoff_files.each do |f|
  #       @distinct_blobs << Grit::GitRuby::Internal::LooseStorage.calculate_sha(File.read(f),'blob')
  #     end
  #   end
  #   @distinct_blobs
  #   # if @distinct_blobs.blank?
  #   #   distinct_blob_ids = []
  #   #   @distinct_blobs = []
  #   #   self.repo.commits.each do |c|
  #   #     c.tree.blobs.each do |b|
  #   #       unless distinct_blob_ids.include?(b.id)            
  #   #         @distinct_blobs << b
  #   #         distinct_blob_ids << b.id
  #   #       end
  #   #     end
  #   #   end      
  #   # end
  #   # @distinct_blobs
  # end
  # 
  # def distinct_blob_ids
  #   self.distinct_blobs.map(&:id)
  # end
  
  
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
          @row.cells << Lt::Cell.new(@row, blob_index,cell_index,blob.id)
        end
        @table.rows << @row.clone
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