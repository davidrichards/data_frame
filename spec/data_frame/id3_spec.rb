require File.join(File.dirname(__FILE__), "/../spec_helper")
require 'data_frame/id3'

describe "DecisionTree" do

  before do
    @filename = File.expand_path(File.join(File.dirname(__FILE__), "../fixtures/discrete_training.csv"))
    @df = DataFrame.from_csv(@filename)
    @test_data = File.read(@filename)
  end
  
  it "should require the decisiontree gem" do
    defined?(DecisionTree::ID3Tree).should eql('constant')
  end
  
  it "should be able to create a decision tree from a data frame" do
    # Come back to this.
    # @df.create_id3(:purchase)
    # @df.id3.train
    # @df.id3.predict(["36 - 55", "masters", "high", "single", 1]).should eql(1)
  end
end