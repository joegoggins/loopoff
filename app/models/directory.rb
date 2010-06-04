# TODO: cache the .aggregated_files array, this is expensive to read and aggregate the directory
# entries for requests to every cell
class Directory < ActiveRecord::Base
  # OVERRIDING ATTRIBUTE STUB
  def slug
    File.basename(self.path)
  end
  
  class FileDoesNotExistForCell < Exception; end
  def dir
    @dir ||= Dir.open(self.path)
  end
  
  # returns 2 tuples, like:
  # ["007", [nil, "007_2.WAV", "007_3.WAV"]]
  #
  def aggregated_files
    if @aggregated_files
      @aggregated_files
    else
      # yields elements like ["007", ["007_2.WAV", "007_3.WAV"]]
      @aggregated_files = self.dir.entries.group_by {|x| x.split('_').first}.sort.delete_if {|x| x.first.match /\./}
      
      # insert nils to make matrix solid, like ["007", [nil, "007_2.WAV", "007_3.WAV"]]
      @aggregated_files.map do |x| 
        if x.last.length != 3
          modded_3_tuple = [nil,nil,nil]
          x.last.each_with_index do |val,index|
            f_number = val.split('_').last.gsub(/\.WAV/,'').to_i # the 2 or 3 part minus the .WAV
            modded_3_tuple[f_number-1] = val            
          end
          x[1]=modded_3_tuple
          x
        else 
          x
        end
      end      
    end
  end
  
  def row_name(x)
    self.aggregated_files[x.to_i][0]
  end
  
  # returns the file name on
  def cell(x,y)
    self.aggregated_files[x.to_i][1][y.to_i]
  end
  
  def file_path_to_cell(x,y)
    f = "#{self.path}/#{self.cell(x,y)}"
    unless File.file?(f)
      raise FileDoesNotExistForCell.new("Dude, check cell(x,y).nil? first before calling this")
    end
    f
  end
  def base_file_name_of_cell(x,y)
    "#{x}_#{y}.WAV"
  end
end
