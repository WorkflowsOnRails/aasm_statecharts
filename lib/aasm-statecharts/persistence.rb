# Blatently stolen from AASM::Persistence and modified just for this
module AASM_StateChart


  module Persistence
    class << self

      def load_persistence(base)

        # Use a fancier auto-loading thingy, perhaps.  When there are more persistence engines.
        hierarchy = base.ancestors.map { |klass| klass.to_s }

        if hierarchy.include?("ActiveRecord::Base")
          require_persistence :active_record
          include_persistence base, :active_record
=begin
        Not Implemented (copied from AASM::Persistence)
        elsif hierarchy.include?("Mongoid::Document")
          require_persistence :mongoid
          include_persistence base, :mongoid
        elsif hierarchy.include?("MongoMapper::Document")
          require_persistence :mongo_mapper
          include_persistence base, :mongo_mapper
        elsif hierarchy.include?("Sequel::Model")
          require_persistence :sequel
          include_persistence base, :sequel
        elsif hierarchy.include?("Dynamoid::Document")
          require_persistence :dynamoid
          include_persistence base, :dynamoid
        elsif hierarchy.include?("CDQManagedObject")
          include_persistence base, :core_data_query
=end
        elsif hierarchy.include?("Redis::Objects")
          require_persistence :redis
          include_persistence base, :redis

        else
          include_persistence base, :plain
        end
      end


      private

      def require_persistence(type)
        require File.join(__dir__, 'persistence', "#{type}_persistence")
      end


      def include_persistence(base, type)
        base.send(:include, constantize("#{capitalize(type)}Persistence"))
      end


      def capitalize(string_or_symbol)
        string_or_symbol.to_s.split('_').map { |segment| segment[0].upcase + segment[1..-1] }.join('')
      end


      def constantize(string)
        AASM_StateChart::Persistence.const_get(string)
      end

    end # class << self

  end # module Persistence

end # module AASM_StateChart
