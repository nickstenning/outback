require File.dirname(__FILE__) + '/../spec_helper'

describe Outback::Task do
  
  before do
    @task = Outback::Task.new
  end

  it "should take an optional block on its constructor, passing itself in as the block parameter" do
    lambda { @task = Outback::Task.new }.should_not raise_error
    temp = nil
    @task = Outback::Task.new do |t|
      temp = t
    end
    temp.should == @task
  end
    
  it "should have blank rollout and rollback procs by default" do
    @task.rollout.call.should be_nil
    @task.rollback.call.should be_nil
  end
  
  it "should define rollout and rollback tasks by calling #rollback and #rollout with a block" do
    @task.rollout { 1 + 2 }
    @task.rollout.call.should == 3
    @task.rollback { 4 + 2 }
    @task.rollback.call.should == 6
  end
  
  describe "(with a rollout and rollback task defined)" do
    before do
      @task.rollout { 1 + 2 }
      @task.rollback { 4 + 2 }
    end
    
    it "should run the rollback/rollout procs when called with #rollout!/#rollback!, returning the return value of the proc" do
      @task.rollout!.should == 3
      @task.rollback!.should == 6
    end
  end
end