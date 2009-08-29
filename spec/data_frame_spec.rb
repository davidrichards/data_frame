require File.join(File.dirname(__FILE__), "/spec_helper")

describe DataFrame, "gem dependencies" do
  
  it "should use RubyGems" do
    defined?(Gem).should eql('constant')
  end
  
  it "should use ActiveSupport" do
    defined?(ActiveSupport).should eql('constant')
  end
  
  it "should use JustEnumerableStats" do
    [1]._jes_average.should eql(1)
  end
  
  it "should use OpenURI" do
    defined?(OpenURI).should eql('constant')
  end
  
  it "should use FasterCSV" do
    defined?(FasterCSV).should eql('constant')
  end
  
  it "should use OpenStruct" do
    defined?(OpenStruct).should eql('constant')
  end

end