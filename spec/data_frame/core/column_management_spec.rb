require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe "Column Management" do
  before do
    @labels = [:these, :are, :the, :labels]
    @df = DataFrame.new(*@labels)
    @df.add [1,2,3,4]
    @df.add [5, 6, 7, 8]
  end
    
  context "append!" do
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
  
  context "move_to_last!" do
    it "should be able to move a column to the end of the data frame, useful for dependency models" do
      @df.labels.should eql(@labels)
      @df.move_to_last!(:these)
      @df.labels.should eql([:are, :the, :labels, :these])
      @df.these.should eql([1,5])
    end
  end
  
  context "rename!" do
    it "should be able to rename a column" do
      @df.rename!(:new_name, :these)
      @df.labels.should eql([:new_name, :are, :the, :labels])
    end
    
    it "should be able to use the new column name with dot notation" do
      v = @df.these.dup
      @df.rename!(:new_name, :these)
      @df.new_name.should eql(v)
    end
  end
  
  context "drop!" do
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
    
  end
  
  context "replace!" do
    before do
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
  
  context "subset_from_columns" do

    it "should be able to create a subset of columns" do
      new_data_frame = @df.subset_from_columns(:these, :labels)
      new_data_frame.should_not eql(@df)
      new_data_frame.labels.should eql([:these, :labels])
      new_data_frame.items.should eql([[1,4],[5,8]])
      new_data_frame.these.should eql([1,5])
    end
  end
  
  context "duplicate!" do
    it "should be able to duplicate a column" do
      @df.duplicate!(:these)
      @df.these1.should eql(@df.these)
    end
    
    it "should use unique names for the duplicate column" do
      @df.duplicate!(:these)
      @df.duplicate!(:these)
      @df.duplicate!(:these)
      @df.these3.should eql(@df.these2)
      @df.these2.should eql(@df.these1)
      @df.these1.should eql(@df.these)
    end
    
    it "should reset the labels list when a column is duplicated" do
      @df.duplicate!(:these)
      @df.labels.should be_include(:these1)
    end
    
    it "should return true, rather than the whole data set" do
      @df.duplicate!(:these).should eql(true)
    end
    
    it "should be able to name the new column" do
      @df.duplicate!(:these, :those)
      @df.these.should eql(@df.those)
      @df.labels.should_not be_include(:these1)
    end
    
    # it "should duplicate categories" do
    #   @df.import([1,1,1,1])
    #   @df.these.add_category(0) {|e| e < 5}
    #   @df.these.add_category(1) {|e| e >= 5}
    #   @df.these.categories.should eql([0,1])
    #   @df.duplicate!(:these)
    #   @df.these1.categories.should eql([0,1])
    # end
  end
  
end