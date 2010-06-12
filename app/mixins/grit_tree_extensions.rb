module Mixins::GritTreeExtensions
  def self.included(caller)
    caller.class_eval do
      def my_aggregated_files
        [["thing",nil,nil,nil]]
      end
      
      def loopoff_table
      end 
      # def distinct_blobs_aggregated
      #   #                                  #  (DDD)_N.WAV                                                #  Blob file names are wavs
      #   self.tree.blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}
      # end

      def my_files
        if @my_files.blank?
          @my_files = []
          self.loopoff_files.each do |f|
            @my_files << MyFile.new(:name => f,
              :size => File.size(f),
              :sha => self.file_ids_hash[File.basename(f)],
              :is_identical => self.db.repo.distinct_blobs.map(&:id).include?(self.file_ids_hash[File.basename(f)])          
            )
          end
        end
        @my_files    
      end
    end
  end
end