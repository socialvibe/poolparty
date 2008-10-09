module PoolParty    
  module Resources
    
    # Wrap all the resources into a class package from 
    def classpackage_with_self(parent=self, &block)
      @cp = PoolParty::Resources::Classpackage.new(parent.options, parent, &block)
      @cp.instance_eval {@resources = parent.resources}
      parent.instance_eval {@resources = nil}
      @cp
    end
                
    class Classpackage < Resource
            
      default_options({
        :name => nil
      })
      
      def initialize(opts={}, parent=self, &block)
        # Take the options of the parents        
        set_parent(parent, false) if parent
        set_vars_from_options(opts) unless opts.empty?
        self.instance_eval &block if block
        # store_block(&block)        
        
        loaded
      end
                        
      def to_string
        returning String.new do |output|
          output << "# #{name.sanitize}"
          output << "\nclass #{name.sanitize} {\n"
          output << resources_string_from_resources(resources)
          output << "\n}\n"
        end
      end
      
      def include_string
        "include #{name.sanitize}"
      end
      
      def name(*args)
        args.empty? ? (@name || parent.name) : @name ||= args.first
      end

    end
    
    def resources_string_from_resources(resources, prev="\t")
      @variables = resources.extract! {|name,resource| name == :variable}
      returning Array.new do |str|
        unless @variables.empty?
          str << "\n# Variables \n"
          @variables.each do |name, variable|
            str << variable.to_string("#{prev}")
          end          
        end
        
        resources.each do |type, resource|
          str << "\n#{prev*2}# #{type}\n"
          str << resource.to_string("#{prev*2}")
        end        
      end.join("\n")
    end
    
  end
end