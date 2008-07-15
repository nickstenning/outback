require File.dirname(__FILE__) + '/../spec_helper'

describe Outback::ShellTask do
  
  before do
    @task = Outback::ShellTask.new("out", "back")
  end
  
  it "should use the first parameter to the rollout command" do
    @task.rollout.should == "out"
  end
  
  it "should use the second parameter as the rollback command" do
    @task.rollback.should == "back"
  end
  
  it "should allow its rollout command to be changed with #rollout=" do
    @task.rollout = "foo"
    @task.rollout.should == "foo"
  end
  
  it "should allow its rollback command to be changed with #rollback=" do
    @task.rollout = "bar"
    @task.rollout.should == "bar"
  end
  
  it "should not be rolled out by default" do
    @task.should_not be_rolled_out
  end
  
  it "should rollout when called with #rollout!" do
    @task.rollout!
    @task.should be_rolled_out
  end
  
  it "should run its commands in the current working directory if #workdir hasn't been set" do
    @task = Outback::ShellTask.new("pwd", "")
    @task.rollout!
    @task.result.chomp.should == Dir.getwd
  end
  
  it "should run its commands in the workdir, if set with #workdir=" do
    @task = Outback::ShellTask.new("pwd", "")
    @task.workdir = "/private/tmp" ## FIXME for *nix systems
    @task.rollout!
    @task.result.chomp.should == @task.workdir
  end
  
  it "should return true on successful #rollout! or #rollback!" do
    @task = Outback::ShellTask.new("echo", "echo")
    @task.rollout!.should be_true
    @task.rollback!.should be_true
  end
  
  it "should return false on unsuccessful #rollout! or #rollback!" do
    @task = Outback::ShellTask.new("I-am-a-command-most-unlikely-to-exist", "I-am-a-command-most-unlikely-to-exist")
    @task.rollout!.should be_false
    @task.rollback!.should be_false
  end
  
  describe "(when rolled out)" do
    
    before do
      @task = Outback::ShellTask.new('pwd', 'pwd')
      @task.rollout!
    end
    
    it "should be rolled out" do
      @task.should be_rolled_out
    end
    
    it "should have an integer exit code" do
      @task.exit_code.should be_a_kind_of(Fixnum)
    end
    
    it "should have a string result" do
      @task.result.should be_a_kind_of(String)
    end
    
    it "should have a string for errors (stderr)" do
      @task.errors.should be_a_kind_of(String)
    end
    
  end

end