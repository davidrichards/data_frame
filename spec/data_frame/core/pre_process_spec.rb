require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe "PreProcess" do
  it "should be able to j_binary_ize! a column, taking its categories and creating a column for each" do
    df = DataFrame.new(:observations)
    df.add [:many]
    df.add [:fine]
    df.add [:things]
    df.add [:are]
    df.add [:available]
    df.j_binary_ize!(:observations)
    df.observations_many.should eql([true, false, false, false, false])
    df.observations_fine.should eql([false, true, false, false, false])
    df.observations_things.should eql([false, false, true, false, false])
    df.observations_are.should eql([false, false, false, true, false])
    df.observations_available.should eql([false, false, false, false, true])
    df.observations.should eql([:many, :fine, :things, :are, :available])
  end
  
  it "should be able to j_binary_ize! a more normal column" do
    df = DataFrame.new(:observations)
    df.import([1,2,3,4,5,4,3,2,1].map{|e| Array(e)})
    df.observations.add_category(:small) {|e| e <= 3}
    df.observations.add_category(:large) {|e| e >= 3}
    df.j_binary_ize!(:observations)
    df.observations_small.should eql([true, true, true, false, false, false, true, true, true])
    df.observations_large.should eql([false, false, false, true, true, true, false, false, false])
  end
  
  it "should be able to j_binary_ize with non-adjacent sets (sets that allow a value to have more than one category)" do
    df = DataFrame.new(:observations)
    df.import([1,2,3,4,5,4,3,2,1].map{|e| Array(e)})
    df.observations.add_category(:small) {|e| e <= 3}
    df.observations.add_category(:large) {|e| e >= 3}
    df.j_binary_ize!(:observations, :allow_overlap => true)
    df.observations_small.should eql([true, true, true, false, false, false, true, true, true])
    df.observations_large.should eql([false, false, true, true, true, true, true, false, false])
  end
  
  it "should be able to hold multiple ideas of a columns categories by resetting the category and re-running j_binary_ize" do
    df = DataFrame.new(:observations)
    df.import([1,2,3,4,5,4,3,2,1].map{|e| Array(e)})
    df.observations.add_category(:small) {|e| e <= 3}
    df.observations.add_category(:large) {|e| e >= 3}
    df.j_binary_ize!(:observations, :allow_overlap => true)
    df.observations.set_categories(:odd => lambda{|e| e.odd?}, :even => lambda{|e| e.even?})
    df.j_binary_ize!(:observations)
    df.observations_small.should eql([true, true, true, false, false, false, true, true, true])
    df.observations_large.should eql([false, false, true, true, true, true, true, false, false])
    df.observations.should eql([1,2,3,4,5,4,3,2,1])
    df.observations_even.should eql([false, true, false, true, false, true, false, true, false])
    df.observations_odd.should eql([true, false, true, false, true, false, true, false, true])
  end

  context "numericize!" do
    
    before do
      @df = DataFrame.new(:observations)
      @df.import([1,2,3,4,5,4,3,2,1].map{|e| Array(e)})
      @df.observations.add_category(:small) {|e| e <= 3}
      @df.observations.add_category(:large) {|e| e > 3}
    end
    
    it "should be able to numericize nominal data" do
      @df.numericize!(:observations)
      @df.numerical_observations.should eql([[1,0],[1,0],[1,0],[0,1],[0,1],[0,1],[1,0],[1,0],[1,0]])
    end
    
  end
  
end