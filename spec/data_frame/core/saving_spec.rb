require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe "Saving" do
  before do
    @df = DataFrame.new(:observations)
    @df.import([1,2,3,4,5,4,3,2,1].map{|e| Array(e)})
    @df.observations.add_category(:small) {|e| e <= 3}
    @df.observations.add_category(:large) {|e| e > 3}
    @filename = "/tmp/numericized_observations"
  end
  
  after do
    `rm -rf #{@filename}`
  end

  it "should be able to save the data frame" do
    @df.numericize!(:observations)
    @df.save(@filename)
    File.read(@filename).should eql(@df.to_csv)
  end

  it "should be able to save the data frame without the header" do
    @df.save(@filename, :include_header => false)
    File.read(@filename).should eql(@df.to_csv(false))
  end
  
  it "should be able to save off a subset" do
    @df = DataFrame.new(:observations, :junk)
    @df.import( [1,2,3,4,5,4,3,2,1].map{ |e| [e,e] } )
    @df.save(@filename, :subset => :observations)
    File.read(@filename).should eql(@df.subset_from_columns(:observations).to_csv)
  end
  
  it "should be able to filter the rows" do
    @df = DataFrame.new(:observations, :junk)
    @df.import( [1,2,3,4,5,4,3,2,1].map{ |e| [e,e] } )
    @df.save(@filename, :subset => :observations)
    @df.observations.add_category(:small) {|e| e <= 3}
    @df.observations.add_category(:large) {|e| e > 3}
    @df.save(@filename, :filter_by_category => {:observations => :small})
    File.read(@filename).should eql(@df.filter_by_category(:observations => :small).to_csv)
  end
  
  it "should have a shortcut for subset, only" do
    @df = DataFrame.new(:observations, :junk)
    @df.import( [1,2,3,4,5,4,3,2,1].map{ |e| [e,e] } )
    @df.save(@filename, :only => :observations)
    File.read(@filename).should eql(@df.subset_from_columns(:observations).to_csv)
  end
  
  it "should have a shortcut for filter_by_category, filter" do
    @df = DataFrame.new(:observations, :junk)
    @df.import( [1,2,3,4,5,4,3,2,1].map{ |e| [e,e] } )
    @df.save(@filename, :subset => :observations)
    @df.observations.add_category(:small) {|e| e <= 3}
    @df.observations.add_category(:large) {|e| e > 3}
    @df.save(@filename, :filter => {:observations => :small})
    File.read(@filename).should eql(@df.filter_by_category(:observations => :small).to_csv)
  end
  
end