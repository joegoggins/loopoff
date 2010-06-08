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
  def self.loopoff_files(full_paths_to_files)
    full_paths_to_files.select do |x|
      # TODO: add x.match(/README/) when ready
      (x.match(/.WAV/)) && File.file?(x)
    end
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
end