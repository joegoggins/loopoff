require 'find'
class Db < Dir
  # returns all paths under loop_db that have a subdir "repo" that in turn has a .git sub-dir  
  # this is a definition of a "Loopoff Db"
  def self.all
    returning [] do |t|
      Dir.chdir("#{RAILS_ROOT}/loop_db") do
        Dir.glob("**/repo/.git").each do |path_to_dot_git|
          t << self.new(File.expand_path("#{path_to_dot_git}/../.."))  
        end
      end
    end
  end
  
  def self.first
    self.all.first
  end
  
  def self.[](db_name)
    self.all.detect {|x| x.name == db_name.to_s}
  end
  
  # A utility helper for filtering a set of file names
  #
  def self.loopoff_file_names(full_paths_to_files)
    full_paths_to_files.select do |x|
      self.is_loopoff_file?(x)
    end
  end
  
  # If you want this to work with rel paths, wrap in Dir.chdir('the_dir') {}
  def self.is_loopoff_file?(path_to_file)
    # TODO: add x.match(/README/) when ready
    (path_to_file.match(/.WAV/i)) && File.file?(path_to_file)
  end
  
  def name
    File.basename(self.path)
  end
  
  def to_param
    self.name
  end
  
  def repo
    @repo ||= Repo.new(self.path + '/repo')
  end
    
  # any dir containing wav files that's not in /repo
  def unarchived_paths(*args)
    t = []
    Dir.chdir(self.path) do
      Find.find('.') do |f|
        if File.basename(f) == 'repo'
          Find.prune 
        elsif File.directory?(f)
          if Dir.entries(f).any? {|e| e.match(/\.wav/i)}              
            t << UnarchivedPath.new(self,File.expand_path(f))
          else
            next
          end
        end
      end
    end
    if args.first.kind_of? Regexp
      return t.select {|x| x.name.match(args.first)}
    elsif args.first.kind_of? String
      return t.detect {|x| x.name == args.first}
    end
    return t
  end
  
  
  ######## RC50 SPECIFIC CRAP BEGIN
  def aggregate_blobs(blobs)

    #     blobs.sort(&:name).each do |blob|
    #       
    #     end
    #     grouped_by_file_prefix = blobs.group_by do |blob|
    #       blob.name.split('_').first
    #     end
    debugger
    #    self.distinct_blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}    
        # grou
        # #                                  #  (DDD)_N.WAV                                                #  Blob file names are wavs
        # .sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}
        # end 
    
    blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}    
  end
  ######## RC50 SPECIFIC CRAP END
end