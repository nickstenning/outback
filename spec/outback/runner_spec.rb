require File.dirname(__FILE__) + '/../spec_helper'

describe Outback::Runner do
  
  it "should load an Outback::Manager, populated with tasks from the YAML file given as the parameter to #new" do
    @runner = Outback::Runner.new(File.dirname(__FILE__) + '/../fixtures/example.yml')
    @runner.manager.should be_a_kind_of(Outback::Manager)
    @runner.manager.should have(4).tasks
    @runner.manager.tasks.first.rollout.should == 'echo "I started."'
  end
  
end