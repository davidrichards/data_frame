require File.join(File.dirname(__FILE__), "/spec_helper")

describe DataFrame do
  
  before do
    @labels = [:these, :are, :the, :labels]
    @df = DataFrame.new(*@labels)
  end
  
  it "should initialize with labels" do
    df = DataFrame.new(*@labels)
    df.labels.should eql(@labels)
  end
  
  it "should initialize with an empty items list" do
    @df.items.should be_is_a(TransposableArray)
    @df.items.should be_empty
  end
  
  it "should be able to add an item" do
    item = [1,2,3,4]
    @df.add_item(item)
    @df.items.should eql([item])
  end

  it "should use just_enumerable_stats" do
    [1,2,3].std.should eql(1.0)
    lambda{[1,2,3].cor([2,3,5])}.should_not raise_error
  end

  context "column and row operations" do
    before do
      @df.add_item([1,2,3,4])
      @df.add_item([5,6,7,8])
      @df.add_item([9,10,11,12])
    end
    
    it "should have a method for every label, the column in the data frame" do
      @df.these.should eql([1,5,9])
    end
    
    it "should make columns easily computable" do
      @df.these.std.should eql([1,5,9].std)
    end

    it "should defer unknown methods to the items in the data frame" do
      @df[0].should eql([1,2,3,4])
      @df << [13,14,15,16]
      @df.last.should eql([13,14,15,16])
      @df.map { |e| e.sum }.should eql([10,26,42,58])
    end
    
    it "should allow optional row labels" do
      @df.row_labels.should eql([])
    end
    
    it "should have a setter for row labels" do
      @df.row_labels = [:other, :things, :here]
      @df.row_labels.should eql([:other, :things, :here])
    end
    
    it "should be able to access rows by their labels" do
      @df.row_labels = [:other, :things, :here]
      @df.here.should eql([9,10,11,12])
    end
    
    it "should make rows easily computable" do
      @df.row_labels = [:other, :things, :here]
      @df.here.std.should be_close(1.414, 0.001)
    end
  end
  
  it "should be able to import more than one row at a time" do
    @df.import([[2,2,2,2],[3,3,3,3],[4,4,4,4]])
    @df.row_labels = [:twos, :threes, :fours]
    @df.twos.should eql([2,2,2,2])
    @df.threes.should eql([3,3,3,3])
    @df.fours.should eql([4,4,4,4])
  end
  
  context "csv" do
    it "should compute easily from csv" do
      contents = %{X,Y,month,day,FFMC,DMC,DC,ISI,temp,RH,wind,rain,area
7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
}
      labels = [:x, :y, :month, :day, :ffmc, :dmc, :dc, :isi, :temp, :rh, :wind, :rain, :area]
      
      @df = DataFrame.from_csv(contents)
      @df.labels.should eql(labels)
      @df.x.should eql([7,7])
      @df.area.should eql([0,0])
    end
  end
  
  it "should be able to remove a column" do
    @df = DataFrame.new :twos, :threes, :fours
    @df.import([[2,3,4], [2,3,4], [2,3,4], [2,3,4]])
    @df.drop!(:twos)
    @df.items.all? {|i| i.should eql([3,4])}
    @df.labels.should eql([:threes, :fours])
  end
  
  
end
