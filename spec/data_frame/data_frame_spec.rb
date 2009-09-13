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
  
  it "should be able to add an item" do
    item = [1,2,3,4]
    @df.add_item(item)
    @df.items.should eql([item])
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
  
  it "should be able to remove a column" do
    @df = DataFrame.new :twos, :threes, :fours
    @df.import([[2,3,4], [2,3,4], [2,3,4], [2,3,4]])
    @df.drop!(:twos)
    @df.items.all? {|i| i.should eql([3,4])}
    @df.labels.should eql([:threes, :fours])
  end
  
  it "should be able to remove more than one column at a time" do
    @df = DataFrame.new :twos, :threes, :fours
    @df.import([[2,3,4], [2,3,4], [2,3,4], [2,3,4]])
    @df.drop!(:twos, :fours)
    @df.items.all? {|i| i.should eql([3])}
    @df.labels.should eql([:threes])
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
  
  context "replace!" do
    before do
      @df.add [1,2,3,4]
      @df.add [5, 6, 7, 8]
      @doubler = lambda{|e| e * 2}
    end

    it "should only replace columns that actually exist" do
      lambda{@df.replace!(:not_a_column, &@doubler)}.should raise_error(
        ArgumentError, /Must provide the name of an existing column./)
      lambda{@df.replace!(:these, &@doubler)}.should_not raise_error
    end

    it "should be able to replace a column with a block" do
      @df.replace!(:these) {|e| e * 2}
      @df.these.should eql([2,10])
    end
    
    it "should be able to replace a column with an array" do
      @a = [5,9]
      @df.replace!(:these, @a)
      @df.these.should eql(@a)
    end
  end
  
  context "filter!" do
    before do
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
  
  context "subset_from_columns" do
    before do
      @df.add [1,2,3,4]
      @df.add [5, 6, 7, 8]
    end

    it "should be able to create a subset of columns" do
      new_data_frame = @df.subset_from_columns(:these, :labels)
      new_data_frame.should_not eql(@df)
      new_data_frame.labels.should eql([:these, :labels])
      new_data_frame.items.should eql([[1,4],[5,8]])
      new_data_frame.these.should eql([1,5])
    end
  end
  
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
  
  context "append!" do
    
    before do
      @df.add [1,2,3,4]
      @df.add [5, 6, 7, 8]
    end
    
    it "should be able to append an array of values to the data frame" do
      @df.append!(:new_column, [5,5])
      @df.new_column.should eql([5,5])
    end
    
    it "should be able to append a default value to the data frame" do
      @df.append!(:new_column, :value)
      @df.new_column.should eql([:value, :value])
    end
    
    it "should use nil as the default value" do
      @df.append!(:new_column)
      @df.new_column.should eql([nil, nil])
    end
  end
end
