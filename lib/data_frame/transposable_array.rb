# The only trick in this array is that it's transpose is memoized until
# it is tainted.  This will reduce computations elegantly. 
class TransposableArray < CallbackArray

  after_taint :clear_cache
  
  orig_transpose = instance_method(:transpose)
  define_method(:transpose) {
    @transpose ||= orig_transpose.bind(self).call
  }
  
  # For debugging and testing purposes, it just feels dirty to always ask
  # for @ta.send(:instance_variable_get, :@transpose) 
  def cache
    @transpose
  end

  def clear_cache
    @transpose = nil
  end
  protected :clear_cache
end