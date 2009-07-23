require File.join(File.dirname(__FILE__), "/../spec_helper")

# TransposableArray is a thorough test on the after_taint method.  Here
# I only test the other callbacks. 
class Register
  def self.next(meth)
    @@count ||= {}
    @@count[meth] ||= 0
    @@count[meth] += 1
  end
  def self.for(meth)
    @@count ||= {}
    @@count[meth]
  end
end

class A < CallbackArray
  before_taint :register_before_taint
  def register_before_taint
    Register.next(:before_taint)
  end

  before_untaint :register_before_untaint
  def register_before_untaint
    Register.next(:before_untaint)
  end
  
  after_untaint :register_after_untaint
  def register_after_untaint
    Register.next(:after_untaint)
  end
end

describe CallbackArray do
  before do
    @a = A.new [1,2,3]
  end
  
  context "before_taint" do
    before do
      @c = Register.for(:before_taint) || 0
    end
    
    after do
      Register.for(:before_taint).should eql(@c + 1)
      @a.should be_tainted
    end
    
    it "should callback before taint" do
      @a.taint
    end

    it "should callback before :[]=" do
      @a[0] = 2
    end

    it "should callback before :<<" do
      @a << 3
    end

    it "should callback before :delete" do
      @a.delete(2)
    end

    it "should callback before :push" do
      @a.push(5)
    end

    it "should callback before :pop" do
      @a.pop
    end

    it "should callback before :shift" do
      @a.shift
    end

    it "should callback before :unshift" do
      @a.unshift(6)
    end

    it "should callback before :map!" do
      @a.map! {|e| e}
    end

    it "should callback before :sort!" do
      @a.sort!
    end

    it "should callback before :reverse!" do
      @a.reverse!
    end

    it "should callback before :collect!" do
      @a.collect! {|e| e}
    end

    it "should callback before :compact!" do
      @a.compact!
    end

    it "should callback before :reject!" do
      @a.reject! {|e| not e}
    end

    it "should callback before :slice!" do
      @a.slice!(1,2)
    end

    it "should callback before :flatten!" do
      @a.flatten!
    end

    it "should callback before :uniq!" do
      @a.uniq!
    end

    it "should callback before :clear" do
      @a.clear
    end

    
  end

  it "should not adjust the array in other methods" do
    @a.at(0)
    @a.sort
    @a.uniq
    @a.find{|e| e}
    Register.for(:before_taint).should be_nil
    @a.should_not be_tainted
  end

  it "should callback before untaint" do
    c = Register.for(:before_untaint) || 0
    @a.taint
    @a.untaint
    Register.for(:before_untaint).should eql(c + 1)
  end

  it "should callback after untaint" do
    c = Register.for(:after_untaint) || 0
    @a.taint
    @a.untaint
    Register.for(:after_untaint).should eql(c + 1)
  end
  
end

