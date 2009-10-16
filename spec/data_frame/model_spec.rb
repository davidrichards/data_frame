require File.join(File.dirname(__FILE__), "/../spec_helper")

describe DataFrame, "model" do
  before do
    @csv = %{a,b,c
1,2,3
2,2,2
4,5,6}
    @df = DataFrame.from_csv(@csv)
  end
  
  it "should be able to define a model with a block" do
    @df.model(:b2) do |m|
      m.b 2
    end
    
    @df.models.table.keys.should eql([:b2])
    @df.models.b2.size.should eql(2)
    @df.models.b2.b.should eql([2,2])
  end
  
  it "should be able to define a model with a range of values" do
    @df.model(:a12) do |m|
      m.a(1..2)
    end
    @df.models.a12.a.should eql([1,2])
  end
  
  it "should be able to define a model with a set of values" do
    @df.model(:a14) do |m|
      m.a [1,4]
    end
    @df.models.a14.a.should eql([1,4])
  end
  
end