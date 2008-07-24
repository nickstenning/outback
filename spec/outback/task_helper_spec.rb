require File.dirname(__FILE__) + '/../spec_helper'

describe Outback::TaskHelper do
  
  before do
    @th = Outback::TaskHelper.new(@manager)
  end
  
  it "should give an empty hash on #cache" do
    @th.cache.should be_a_kind_of(Hash)
    @th.cache.should be_empty
  end
    
  it "should give the current working directory on #workdir" do
    @th.workdir.should == Dir.getwd
  end
  
  it "should provide a #sys method which makes a system call, returning a hash with stdout, stderr and exit_status" do
    result = @th.sys("pwd")
    result[:stdout].should == Dir.getwd + "\n"
    result[:stderr].should == ""
    result[:exit_status].should == 0
  end
  
  describe "(with a manager set)" do
    before do
      @cache = {}
      @manager = mock(:manager, :cache => @cache, :workdir => '/myworkdir')
      @th = Outback::TaskHelper.new(@manager)
    end
    
    it "should give the manager's cache on #cache" do
      @th.cache.should == @cache
    end
    
    it "should give the manager's workdir on #workdir" do
      @th.workdir.should == '/myworkdir'
    end
    
    it "should execute calls to sys in the workdir" do
      @manager.should_receive(:workdir).and_return("/")
      lambda { @result = @th.sys("pwd") }.should_not raise_error
      @result[:stdout].should == "/\n"
    end
  end
end
