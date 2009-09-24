require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe "Import" do
  
  before do
    @labels = [:these, :are, :the, :labels]
    @df = DataFrame.new(*@labels)
  end
  
  it "should be able to add an item" do
    item = [1,2,3,4]
    @df.add_item(item)
    @df.items.should eql([item])
  end

  it "should be able to import more than one row at a time" do
    @df.import([[2,2,2,2],[3,3,3,3],[4,4,4,4]])
    @df.row_labels = [:twos, :threes, :fours]
    @df.twos.should eql([2,2,2,2])
    @df.threes.should eql([3,3,3,3])
    @df.fours.should eql([4,4,4,4])
  end

  it "should be able to import only one row" do
    @df.import([2,2,2,2])
    @df.these.should eql([2])
  end

  it "should be able to import a reference to csv" do
    contents = %{7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
}

    @labels = [:x, :y, :month, :day, :ffmc, :dmc, :dc, :isi, :temp, :rh, :wind, :rain, :area]
    @df = DataFrame.new(@labels)
    @df.import(contents)
    @df.x.should eql([7,7])
    @df.area.should eql([0,0])
  end
  
end