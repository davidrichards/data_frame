require File.join(File.dirname(__FILE__), "/../spec_helper")

describe DataFrame do
  
  before do
    @labels = [:these, :are, :the, :labels]
    @df = DataFrame.new(*@labels)
  end
  
  it "should initialize with labels" do
    df = DataFrame.new(*@labels)
    df.labels.should eql(@labels)
  end
  
  it "should have an optional name" do
    @df.name = :some_name
    @df.name.should eql(:some_name)
  end
  it "should initialize with an empty items list" do
    @df.items.should be_is_a(TransposableArray)
    @df.items.should be_empty
  end
  
  it "should use just_enumerable_stats" do
    [1,2,3].std.should eql(1)
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
      @df.here.sum.should eql(42)
    end
  end
  
  it "should be able to initialize from an array" do
    contents = %{7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
}
    
    @labels = [:x, :y, :month, :day, :ffmc, :dmc, :dc, :isi, :temp, :rh, :wind, :rain, :area]
    @df = DataFrame.new(@labels)
    @df.import(contents)
    @df.labels.should eql(@labels)
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
    
    it "should infer a name when importing from a file" do
      filename = "/tmp/data_frame_spec.csv"
      contents = %{X,Y,month,day,FFMC,DMC,DC,ISI,temp,RH,wind,rain,area
7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
}
      File.open(filename, 'w') {|f| f.write contents}
      @df = DataFrame.from_csv(filename)
      @df.name.should eql('Data Frame Spec')
      `rm -rf #{filename}`
    end
  end
  
  it "should offer a hash-like structure of columns" do
    @df.add [1,2,3,4]
    @df.add [5, 6, 7, 8]
    @df.columns[:these].should eql([1, 5])
    @df.columns[:are].should eql([2, 6])
    @df.columns[:the].should eql([3, 7])
    @df.columns[:labels].should eql([4, 8])
  end
  
  it "should alias items with rows" do
    @df.add [1,2,3,4]
    @df.add [5, 6, 7, 8]
    @df.rows.should eql(@df.items)
  end
  
  it "should be able to export a hash" do
    @df.add [1,2,3,4]
    @df.add [5, 6, 7, 8]
    hash = @df.to_hash
    values = [[1,5],[2,6],[3,7],[4,8]]
    hash.keys.size.should eql(@labels.size)
    hash.keys.all? {|e| @labels.should be_include(e)}
    hash.values.size.should eql(@labels.size)
    hash.values.all? {|e| values.should be_include(e)}
  end
  
  it "should use variables like labels" do
    @df.labels.should eql(@labels)
    @df.variables.should eql(@labels)
  end
  
  
end
