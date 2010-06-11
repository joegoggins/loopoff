module Mixins::GritCommitExtensions
  def self.included(caller)
    caller.class_eval do 
      def self.x
        :x
      end
      def t
        't'
      end
    end
  end  
end
