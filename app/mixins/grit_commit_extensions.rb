module Mixins::GritCommitExtensions
  def self.included(caller)
    caller.class_eval do 
      def self.x
        :x
      end
      def t
        't'
      end
      
      def to_param
        self.id
      end
      # TODO: make this not brittle as hell
      def extract_row_name_from_message(row_name,aggregation_method=:name_prefix)
        begin
          self.message.to_a.select {|x| x.match(Regexp.new("^" + row_name))}.map do |t|
            t.split(' ')[1..-1].join(' ')
          end          
        rescue
          "Sorry from GritCommitExtensions"
        end
      end             
    end
  end  
end
