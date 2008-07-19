module Outback
  
  module YAML
    
    def self.load( yaml_string )
      manager = Manager.new
      tasks = ::YAML.load(yaml_string)
      tasks.each do |task|
        task = [task['out'], task['back']]
        manager.tasks << Outback::ShellTask.new(*task)
      end
      return manager
    end
    
    def self.load_file( yaml_file )
      yaml = File.read( yaml_file )
      load( yaml )
    end
              
  end
  
end
