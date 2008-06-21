require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

describe Outback::YAML do
  
  before do
    @yaml =<<-EOM.gsub(/^\s{4}/, '')
    -
      - touch y
      - rm y
    -
      - touch x
      - rm x
    EOM
    @file = '/tmp/outback_yaml_spec_tmp'
    File.open(@file, 'w') { |f| f.puts @yaml }
  end
  
  after do
    File.delete(@file)
  end
  
  describe do
    it "should return an Outback::Manager object" do 
      Outback::YAML.load(@yaml).should be_a_kind_of(Outback::Manager)
      Outback::YAML.load_file(@file).should be_a_kind_of(Outback::Manager)
    end
    it "should return an Outback::Manager object with as many tasks as the YAML passed into it" do
      Outback::YAML.load(@yaml).should have(2).tasks
      Outback::YAML.load_file(@file).should have(2).tasks
    end
    it "should add instances of Outback::ShellTask to the Outback::Manager's task array" do
      manager = Outback::YAML.load(@yaml)
      manager.tasks.first.should be_a_kind_of(Outback::ShellTask)
    end
    it "should set the rollout_command to the first element of the YAML array" do
      manager = Outback::YAML.load(@yaml)
      manager.tasks[0].rollout_command.should == "touch y"
      manager.tasks[1].rollout_command.should == "touch x"
    end
    it "should set the rollback_command to the second element of the YAML array" do
      manager = Outback::YAML.load(@yaml)
      manager.tasks[0].rollback_command.should == "rm y"
      manager.tasks[1].rollback_command.should == "rm x"
    end
  end
end
