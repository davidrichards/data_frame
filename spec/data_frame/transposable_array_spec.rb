require File.join(File.dirname(__FILE__), "/../spec_helper")

describe TransposableArray do
  before do
    @ta = TransposableArray.new [[1,2,3],[4,5,6],[7,8,9]]
    @t = [[1,4,7],[2,5,8],[3,6,9]]
  end
  
  it "should be able to transpose itself" do
    @ta.transpose.should eql(@t)
  end
  
  it "should cache the transpose" do
    @ta.cache.should be_nil
    @ta.transpose
    @ta.cache.should eql(@t)
  end
  
  it "should clear the cache on taint" do
    @count = nil
    @ta.transpose
    @ta.taint
    @ta.cache.should be_nil
  end
  
  it "should clear the cache on []=" do
    @ta.transpose
    @ta[0] = 1
    @ta.cache.should be_nil
  end

  it "should clear the cache on <<" do
    @ta.transpose
    @ta << 1
    @ta.cache.should be_nil
  end

  it "should clear the cache on delete" do
    @ta.transpose
    @ta.delete(0)
    @ta.cache.should be_nil
  end

  it "should clear the cache on push" do
    @ta.transpose
    @ta.push(1)
    @ta.cache.should be_nil
  end

  it "should clear the cache on pop" do
    @ta.transpose
    @ta.pop
    @ta.cache.should be_nil
  end

  it "should clear the cache on shift" do
    @ta.transpose
    @ta.shift
    @ta.cache.should be_nil
  end

  it "should clear the cache on unshift" do
    @ta.transpose
    @ta.unshift(1)
    @ta.cache.should be_nil
  end

  it "should clear the cache on map!" do
    @ta.transpose
    @ta.map!{ |e| e }
    @ta.cache.should be_nil
  end

  it "should clear the cache on sort!" do
    @ta.transpose
    @ta.sort!
    @ta.cache.should be_nil
  end

  it "should clear the cache on reverse!" do
    @ta.transpose
    @ta.reverse!
    @ta.cache.should be_nil
  end

  it "should clear the cache on collect!" do
    @ta.transpose
    @ta.collect! {|e| e}
    @ta.cache.should be_nil
  end

  it "should clear the cache on compact!" do
    @ta.transpose
    @ta.compact!
    @ta.cache.should be_nil
  end

  it "should clear the cache on reject!" do
    @ta.transpose
    @ta.reject! {|e| e}
    @ta.cache.should be_nil
  end

  it "should clear the cache on slice!" do
    @ta.transpose
    @ta.slice!(1,2)
    @ta.cache.should be_nil
  end

  it "should clear the cache on flatten!" do
    @ta.transpose
    @ta.flatten!
    @ta.cache.should be_nil
  end

  it "should clear the cache on uniq!" do
    @ta.transpose
    @ta.uniq!
    @ta.cache.should be_nil
  end

  it "should clear the cache on clear" do
    @ta.transpose
    @ta.clear
    @ta.cache.should be_nil
  end

  it "should not adjust the array in other methods" do
    @ta.transpose
    @ta.at(0)
    @ta.sort
    @ta.uniq
    @ta.find{|e| e}
    @ta.cache.should eql(@t)
  end
end


