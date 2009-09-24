require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe "Filter" do
  before do
    @labels = [:these, :are, :the, :labels]
    @df = DataFrame.new(*@labels)
    @df.add [1,2,3,4]
    @df.add [5, 6, 7, 8]
  end
  
  it "should be able to filter a data frame with a block using an OpenStruct for each row" do
    @df.filter!(:open_struct) {|row| row.these == 5}
    @df.items.should eql([[5, 6, 7, 8]])
  end
  
  it "should be able to filter a data frame with a block using a Hash for each row" do
    @df.filter!(:hash) {|row| row[:these] == 5}
    @df.items.should eql([[5, 6, 7, 8]])
  end
  
  S4 = Struct.new(:one, :two, :three, :four)
  it "should be able to filter a data frame with a block using another class that uses the row as input" do
    @df.filter!(S4) {|row| row.one == 5}
    @df.items.should eql([[5, 6, 7, 8]])
  end
  
  it "should be able to filter a data frame with a block using an array for each row" do
    @df.filter! {|row| row.first == 5}
    @df.items.should eql([[5, 6, 7, 8]])
  end
  
  it "should be able to do fancy things with the row as the filter" do
    @df.filter! {|row| row.sum > 10}
    @df.items.should eql([[5, 6, 7, 8]])
  end
  
  it "should be able to generate a new data frame with filter" do
    new_df = @df.filter(:open_struct) {|row| row.these == 5}
    new_df.items.should eql([[5, 6, 7, 8]])
    @df.items.should eql([[1, 2, 3, 4], [5, 6, 7, 8]])
  end
  
end

context "filter_by_category" do
  
  before do
    @df = DataFrame.new(:weather, :date)

    (1..31).each do |i|
      @df.add [(i % 3 == 1) ? :fair : :good, Date.parse("07/#{i}/2009")]
    end

    @d1 = Date.parse("07/15/2009")
    @d2 = Date.parse("07/31/2009")

  end
  
  it "should be able to filter by category" do
    filtered = @df.filter_by_category(:weather => :good)
    filtered.weather.uniq.should eql([:good])
    @df.weather.uniq.should be_include(:fair)
  end
  
  it "should be able to manage ranges for filter values" do
    filtered = @df.filter_by_category(:date => (@d1..@d2))
    filtered.date.should_not be_include(Date.parse("07/01/2009"))
    filtered.date.should_not be_include(Date.parse("07/14/2009"))
    filtered.date.should be_include(Date.parse("07/15/2009"))
    filtered.date.should be_include(Date.parse("07/31/2009"))
    @df.date.should be_include(Date.parse("07/01/2009"))
  end
  
  it "should be able to take an array of values to filter with" do
    filtered = @df.filter_by_category(:date => [@d1, @d2])
    filtered.date.should_not be_include(Date.parse("07/01/2009"))
    filtered.date.should be_include(Date.parse("07/15/2009"))
    filtered.date.should be_include(Date.parse("07/31/2009"))
  end
  
  it "should have a destructive version" do
    @df.filter_by_category!(:date => [@d1, @d2])
    @df.date.should_not be_include(Date.parse("07/01/2009"))
    @df.date.should be_include(Date.parse("07/15/2009"))
    @df.date.should be_include(Date.parse("07/31/2009"))
  end
  
end