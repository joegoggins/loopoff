module Mixins::GritTreeExtensions
  def self.included(caller)
    caller.class_eval do
      # LOOPOFF TABLE INTERFACE BEGIN
      def cells
        if @cells.blank?
          @cells = []
          #@commit.message.to_a.select {|x| x.match(Regexp.new("^" + "028"))}.map {|t| {:title => t.split(' ')[1..-1].join(' ')}}
          self.loopoff_blobs.each do |b|            
            @cells << Lt::BlobCell.new(:name => b.name,
              :size => nil, # b.size is expensive to compute, hell with it
              :sha => b.id,
              :is_identical => false      
                  
            )
          end
        end
        @cells    
      end

      def rows
        @rows = []
        aggregated_blobs.to_a.each do |tuple|
          @rows << Lt::Row.new(:name => tuple.first,:cells => tuple.last)
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

      # def name
      #   
      # end

      def to_param
        self.id
      end

      # def basename
      #   File.basename(self.path)
      # end

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
      
      def contains_loopoff_files?
        !loopoff_blobs.empty?
      end

      def loopoff_blobs
        if @loopoff_blobs.blank?
          @loopoff_blobs = self.blobs.select {|x| Db.is_loopoff_file_name?(x.name)}
        end
        @loopoff_blobs
      end
      
      # paths in the repo that contain loopoff_blobs
      def loopoff_child_trees
        returning [] do |a|
          self.trees.each do |t|
            if t.contains_loopoff_files?
              a << t
            end
          end  
        end        
      end
      
      def aggregated_blobs
        if @aggregated_blobs.blank?
          @aggregated_blobs =[]
        end
        @aggregated_blobs = self.cells.group_by do |lt_cell| 
          lt_cell.aggregation_string
        end
        
        @aggregated_blobs.map do |x|
          if x.last.length != 3
            modded_3_tuple = [nil,nil,nil]
            x.last.each_with_index do |lt_cell,index|
              # this ensures the _1 _2 or _3 ends up in the right place
              f_number = lt_cell.name.split('_').last.gsub(/\.WAV/i,'').to_i # the 2 or 3 part minus the .WAV
              modded_3_tuple[f_number-1] = lt_cell            
            end
            x[1]=modded_3_tuple
            x
          else 
            x
          end
        end        
        @aggregated_blobs
      end
      # def my_aggregated_file_hash
      #        if @my_aggregated_file_hash
      #          @my_aggregated_file_hash
      #        else
      #          # yields elements like ["007", ["007_2.WAV", "007_3.WAV"]]
      #          @my_aggregated_file_hash = self.cells.group_by do |lt_cell|
      #            lt_cell.basename.split('_').first
      #          end
      #             #{|x| File.basename(x.name)}.group_by {|x| x.split('_').first}.sort
      # 
      #          # insert nils to make matrix solid, like ["007", [nil, "007_2.WAV", "007_3.WAV"]]
      #          @my_aggregated_file_hash.map do |x| 
      #            if x.last.length != 3
      #              modded_3_tuple = [nil,nil,nil]
      #              x.last.each_with_index do |lt_cell,index|
      #                f_number = lt_cell.basename.split('_').last.gsub(/\.WAV/,'').to_i # the 2 or 3 part minus the .WAV
      #                modded_3_tuple[f_number-1] = lt_cell            
      #              end
      #              x[1]=modded_3_tuple
      #              x
      #            else 
      #              x
      #            end
      #          end
      #        end
      #      end
      # include Enumerable
      # def each
      #   self.blobs.sort_by(&:name).each do |b|
      #     yield b
      #   end
      # end
      
      # def rows
      #   
      # end
      # 
      # def cells
      #   self.entries
      # end
    end
  end
end