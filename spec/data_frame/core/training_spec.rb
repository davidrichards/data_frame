require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe "Training" do
  before do
    @df = DataFrame.new(:one)
    @df.import((0...100).to_a)
  end

  it "should be able to create a proportional training set from a data frame" do
    @df.training_set(:n => 3)
    @df.training_set.size.should eql(3)
    @df.training_set.all? {|e| @df.items.should be_include(e)}
  end
  
  it "should use the same training set unless reset is passed to it" do
    @df.training_set(:n => 5)
    @df.training_set.should eql(@df.training_set)
    old = @df.training_set
    @df.training_set(:reset => true, :n => 5)
    @df.training_set.should_not eql(old)
  end
  
  it "should be able to create a proportional training set" do
    @df.training_set(:proportion => 0.6)
    @df.training_set.size.should eql(60)
    @df.training_set(:proportion => 0.42, :reset => true)
    @df.training_set.size.should eql(42)
    @df.training_set(:proportion => 0, :reset => true)
    @df.training_set.size.should eql(0)
    @df.training_set(:proportion => 1, :reset => true)
    @df.training_set.size.should eql(100)
  end
  
  it "should not have a set size exceeding the items size" do
    @df.training_set(:proportion => 2)
    @df.training_set.size.should eql(100)
    @df.training_set(:n => 200, :reset => true)
    @df.training_set.size.should eql(100)
  end
  
  it "should not have any items when the proportion is calculated below 0" do
    @df.training_set(:proportion => -2)
    @df.training_set.size.should eql(0)
    @df.training_set(:n => -2, :reset => true)
    @df.training_set.size.should eql(0)
  end
  
  it "should have a default proportion of 80%" do
    @df.training_set.size.should eql(80)
  end
end