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
            if self.tree.contains_loopoff_files?
              tree.aggregated_blobs.to_a.each do |tuple|
                @rows << Lt::Row.new(:name => tuple.first,:cells => tuple.last)
              end
            end
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
    end
  end  
end
