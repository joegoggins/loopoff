module Mixins::GritRepoExtensions
  def self.included(caller)
    caller.class_eval do 
      # LOOPOFF TABLE INTERFACE BEGIN          
      def cells
        if @cells.blank?
          @cells = []
          self.commits.each do |commit|
            @cells += commit.tree.cells
            commit.tree.all_loopoff_child_trees.each do |tree|
              @cells += tree.cells
            end
          end              
        end
        @cells
      end
      
      def rows
        if @rows.blank?
          @rows = []
          self.commits.each do |commit|
            agg_blobs = commit.tree.aggregated_blobs.to_a            
            commit.tree.all_loopoff_child_trees.each do |tree|
              agg_blobs += tree.aggregated_blobs.to_a
            end
            agg_blobs.each do |tuple|
              @rows << Lt::Row.new(:name => tuple.first,
                :cells => tuple.last,
                :title_from_commit_message => commit.extract_row_name_from_message(tuple.first)  
              )              
            end
            
            # TODO: remove duplicate rows
          end              
        end
        @rows
      end
      
      # DUPLICATED
      def cell(x,y)
        if self.rows[x.to_i].nil?
          nil
        else
          self.rows[x.to_i].cells[y.to_i]
        end
      end
      
      def to_param
        self.id
      end
      
      def basename
        if self.name.nil?
          return "."
        else
          super
        end        
      end

          # def loopoff_file_names
          #   Db.loopoff_file_names(self.entries.map {|x| File.join(self.path,x)})
          # end


          # LOOPOFF TABLE INTERFACE END
          
      # REFACTORED, NOT TESTED
      def each_blob
        self.commits.each do |commit|
          commit.tree.blobs.each do |blob|
            yield blob
          end
          commit.tree.all_loopoff_child_trees.each do |tree|
            tree.blobs.each do |blob|
              yield blob
            end
          end
        end        
      end
          
      # REFACTORED, NOT TESTED
      def distinct_blobs
       if @distinct_blobs.blank?
         @distinct_blobs = []
         distinct_blob_ids = []
         self.each_blob do |b|
           unless distinct_blob_ids.include?(b.id)            
             @distinct_blobs << b
             distinct_blob_ids << b.id
           end           
         end
       end
       @distinct_blobs
      end

      def distinct_blob_ids
       self.distinct_blobs.map {|x| x.id}
      end  
      def distinct_blobs_aggregated
       #                                  #  (DDD)_N.WAV                                                #  Blob file names are wavs
       self.distinct_blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}
      end    
    end
  end  
end
