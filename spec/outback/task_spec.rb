require File.dirname(__FILE__) + '/../spec_helper'

describe Outback::Task do
  
  before do
    @task = Outback::Task.new
  end

  it "should allow its rollout method to be defined with #rollout" do
    rollout_proc = lambda { |t| t.puts "rollout" }
        
    lambda do
      @task.rollout &rollout_proc
    end.should_not raise_error
    
    @task.rollout.should == [0, "rollout\n", ""]
  end
  
  it "should allow its rollback method to be defined with #rollback" do
    rollback_proc = lambda { |t| t.puts "rollback" }
    
    lambda do
      @task.rollback &rollback_proc
    end.should_not raise_error

    @task.rollback.should == [0, "rollback\n", ""]
  end
  
  it "should have a rollout method" do
    @task.should respond_to(:rollout)
  end
  
  it "should have a rollback method" do
    @task.should respond_to(:rollback)
  end
  
  it "should return an exit code and the command output when rollout or rollback is run" do
    returns = @task.rollout
    returns[0].should be_a_kind_of(Numeric)
    returns[1].should be_a_kind_of(String)
    returns[2].should be_a_kind_of(String)
  end
  
  it "should provide a 'sys' method to rollout and rollback blocks to allow system calls" do
    @task.rollout do |t|
      t.sys 'echo', 'system call'
    end
    ret = []
    lambda { ret = @task.rollout }.should_not raise_error
    ret[0].should == 0
    ret[1].should match(/\[\d+\] system call\n/)
    ret[2].should be_empty
  end
  
  it "should catch failed system commands and provide an appropriate exit code" do
    @task.rollout do |t|
      t.sys "nonexistent"
    end
    ret = []
    lambda { ret = @task.rollout }.should_not raise_error
    ret[0].should == 1
  end  
end