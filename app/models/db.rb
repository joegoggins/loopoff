# DEPRECATE DB CLASS ALTOGETHER
# DEPRECATE DB CLASS ALTOGETHER
# DEPRECATE DB CLASS ALTOGETHER
# DEPRECATE DB CLASS ALTOGETHER
# DEPRECATE DB CLASS ALTOGETHER

# REPLACE WITH Repo
require 'find'
class Db < Dir
  
  # DEFINES THE FILES THAT LOOPOFF CARES ABOUT IN A GIVEN @blob.name or @file.basename
  # TODO: DEPRECATE
  def self.is_loopoff_file_name?(the_basename)
    the_basename.match(/.wav/i)
  end
  
  # returns all paths under loop_db that have a subdir "repo" that in turn has a .git sub-dir  
  # this is a definition of a "Loopoff Db"
  def self.all
    returning [] do |t|
      t << self.new(File.expand_path("#{RAILS_ROOT}/loop_db/"))  
    end
  end
  
  def self.first
    self.all.first
  end
  
  def self.[](db_name)
    self.first # TOTALLY WEIRD CRAP DEPRECATE DB CLASS ALTOGETHER
    
    # self.all.detect {|x| x.name == db_name.to_s}
  end
    
  def name
    File.basename(self.path)
  end
  
  def to_param
    self.name
  end
  
  def repo
    @repo ||= Grit::Repo.new(self.path)
  end
    
  # any dir containing wav files that's not in /repo
  def unarchived_paths(*args)
    t = []
    Dir.chdir(self.path) do
      Find.find('unarchived') do |f|
        if false
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