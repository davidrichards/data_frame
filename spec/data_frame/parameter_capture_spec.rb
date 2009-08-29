require File.join(File.dirname(__FILE__), "/../spec_helper")

describe ParameterCapture do
  
  it "should take a block for a column list" do
    pc = ParameterCapture.new do |p|
      p.a 1
      p.b 2
    end
    pc.parameters.table.should == {:a => 1, :b => 2}
  end
  
  it "should be able to capture an array as a parameter, meaning an or-condition" do
    pc = ParameterCapture.new do |p|
      p.or_condition [1,2]
    end
    pc.parameters.or_condition.should eql([1,2])
  end
  
  it "should be able to capture a range as a parameter, meaning a continuous-or-condition" do
    pc = ParameterCapture.new do |p|
      p.a (1..2)
    end
    pc.parameters.a.should eql((1..2))
  end
  
  it "should play setter/getter schizophrenia" do
    pc = ParameterCapture.new {}
    pc.show 1
    pc.show.should eql(1)
  end
end