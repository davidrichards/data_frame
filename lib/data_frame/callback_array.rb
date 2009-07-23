# This overloads the tainting methods in array with callbacks.  So, I
# can block all changes to an array, or broadcast to observers after a
# change, or limit the size of an array. It really just opens up the array to one more dimension: change.  Before and after change, stack up any activity to block or enhance the experience.  There are also callbacks on untaint.  The tainting methods actually 
class CallbackArray < Array
  
  include ActiveSupport::Callbacks
  define_callbacks :before_taint, :after_taint, :before_untaint, :after_untaint

  def wrap_call(safe_method, *args)
    callback_result = run_callbacks(:before_taint)
    if callback_result
      result = self.send(safe_method, *args)
      self.orig_taint
      run_callbacks(:after_taint)
    end
    result
  end
  protected :wrap_call
  
  # Need the original taint for all tainting methods
  alias :orig_taint :taint
  def taint
    callback_result = run_callbacks(:before_taint)
    if callback_result
      result = self.orig_taint
      run_callbacks(:after_taint)
    end
    result
  end

  # No other method needs orig_untaint, so building this in the cleanest
  # way possible. 
  orig_untaint = instance_method(:untaint)
  define_method(:untaint) {
    callback_result = run_callbacks(:before_untaint)
    if callback_result
      val = orig_untaint.bind(self).call
      run_callbacks(:after_untaint)
    end
    val
  }
  
  alias :nontainting_assign :[]=
  def []=(index, value)
    wrap_call(:nontainting_assign, index, value)
  end
  
  alias :nontainting_append :<<
  def <<(value)
    wrap_call(:nontainting_append, value)
  end
  
  alias :nontainting_delete :delete
  def delete(value)
    wrap_call(:nontainting_delete, value)
  end
  
  alias :nontainting_push :push
  def push(value)
    wrap_call(:nontainting_push, value)
  end
  
  alias :nontainting_pop :pop
  def pop
    wrap_call(:nontainting_pop)
  end
  
  alias :nontainting_shift :shift
  def shift
    wrap_call(:nontainting_shift)
  end
  
  alias :nontainting_unshift :unshift
  def unshift(value)
    wrap_call(:nontainting_unshift, value)
  end
  
  alias :nontainting_map! :map!
  def map!(&block)
    callback_result = run_callbacks(:before_taint)
    if callback_result
      result = nontainting_map!(&block)
      self.orig_taint
      run_callbacks(:after_taint)
    end
    result
  end
  
  alias :nontainting_sort! :sort!
  def sort!(&block)
    callback_result = run_callbacks(:before_taint)
    if callback_result
      result = nontainting_sort!(&block)
      self.orig_taint
      run_callbacks(:after_taint)
    end
    result
  end
  
  alias :nontainting_reverse! :reverse!
  def reverse!
    wrap_call(:nontainting_reverse!)
  end
  
  alias :nontainting_collect! :collect!
  def collect!(&block)
    callback_result = run_callbacks(:before_taint)
    if callback_result
      result = nontainting_collect!(&block)
      self.orig_taint
      run_callbacks(:after_taint)
    end
    result
  end
  
  alias :nontainting_compact! :compact!
  def compact!
    wrap_call(:nontainting_compact!)
  end
  
  alias :nontainting_reject! :reject!
  def reject!(&block)
    callback_result = run_callbacks(:before_taint)
    if callback_result
      result = nontainting_reject!(&block)
      self.orig_taint
      run_callbacks(:after_taint)
    end
    result
  end
  
  alias :nontainting_slice! :slice!
  def slice!(*args)
    wrap_call(:nontainting_slice!, *args)
  end
  
  alias :nontainting_flatten! :flatten!
  def flatten!
    wrap_call(:nontainting_flatten!)
  end

  alias :nontainting_uniq! :uniq!
  def uniq!
    wrap_call(:nontainting_uniq!)
  end
  
  alias :nontainting_clear :clear
  def clear
    wrap_call(:nontainting_clear)
  end

end