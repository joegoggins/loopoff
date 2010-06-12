class UnarchivedPath < Dir  
  attr_reader :db, :repo, :cells
  def initialize(db, absolute_path)
    @db = db
    super(absolute_path)    
  end
  
  # TODO number_of_new_files
  # number_of_new_rows
  
  
  # LOOPOFF TABLE INTERFACE BEGIN
  def cells
    if @cells.blank?
      @cells = []
      self.loopoff_file_names.each do |f|
        @cells << Lt::Cell.new(:name => f,
          :size => File.size(f),
          :sha => self.file_ids_hash[File.basename(f)],
          :is_identical => self.db.repo.distinct_blobs.map(&:id).include?(self.file_ids_hash[File.basename(f)])          
        )
      end
    end
    @cells    
  end

  def new_cells
    self.cells.select {|x| !x.is_identical}
  end
  
  def rows
    @rows = []
    my_aggregated_file_hash.to_a.each do |tuple|
      @rows << Lt::Row.new(:name => tuple.first,:cells => tuple.last)
    end
    @rows
  end

  def cell(x,y)
    if self.rows[x.to_i].nil?
      nil
    else
      self.rows[x.to_i].cells[y.to_i]
    end
  end
  
  def name
    self.path.gsub(@db.path + '/','')
  end
  alias_method :relative_path, :name
  alias_method :to_param, :name

  def to_param
    self.name
  end
  
  def basename
    File.basename(self.path)
  end

  # LOOPOFF TABLE INTERFACE END  

  def repo
    @repo ||= Grit::Repo.new(self.path)
  end
  
  ################
  # PROTECTED METHODS BELOW
  ################
  
  protected
  def my_aggregated_file_hash
    if @my_aggregated_file_hash
      @my_aggregated_file_hash
    else
      # yields elements like ["007", ["007_2.WAV", "007_3.WAV"]]
      @my_aggregated_file_hash = self.cells.group_by do |my_file|
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
      self.cells.each do |f|
        @my_file_hash[File.basename(f.name)] = f
      end
    end
    @my_file_hash
  end
    
  # the default for export overridable in controller
  def export_path
    "exp_#{self.basename.gsub(/[^A-Za-z0-9_]/,'_')}"
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
        self.loopoff_file_names.each do |f|
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
  
  def loopoff_file_names
    Db.loopoff_file_names(self.entries.map {|x| File.join(self.path,x)})
  end
end