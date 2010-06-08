desc "add a new snapshot to the repo"
task :import => :environment do
  require 'fileutils'
  raise "specify a source" if ENV['source'].blank?
  @unarchived_path = Db[:rc50].unarchived_paths(ENV['source'])
  raise "no unarchived_path called #{ENV['source']}" if @unarchived_path.blank?

  @new_blobs = @unarchived_path.new_blobs
  if @new_blobs.empty?
    puts "There are no new files in #{@unarchived_path.path}"
    exit
  else
    @new_blobs.each do |b|
      puts "#{b.name} #{b.size} #{b.id}"
    end
  end
  
  puts "Do you want to copy these files into the repo replacing the existing ones in the current repo HEAD?"
  r = $stdin.gets
  if r.match(/y/i)
    @new_blobs.each do |b|
      # aka cp 010_1.WAV rc50/repo/010_1.WAV
      source = File.join(@unarchived_path.path,b.name)
      target = File.join(@unarchived_path.db.path,'/repo/',b.name)
      if File.exists?(target)
        FileUtils.rm_rf(target)
      end
      FileUtils.cp(source, target)  
    end
    puts "mkay, now:"
    puts "cd #{File.join(@unarchived_path.db.path,'/repo/')}"
    puts "git add *"
    puts "git commit -a -v"
  else
    puts 'Action Cancelled'
  end
end