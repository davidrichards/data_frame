module Training #:nodoc:
  
  # Remove the training set if reset
  # Return cached training_set, if there is one
  # Get the proportion or 80%
  # Get the number of items to choose, n, or a proportion of the items
  # Store and return n random items
  def training_set(opts={})
    @training_set = nil if opts[:reset]
    return @training_set if @training_set
    
    items_size = self.items.size
    proportion = opts.fetch(:proportion, 0.8)
    n = opts[:n]
    n ||= (items_size * proportion).to_i
    n = self.items.size if n > items_size
    n = 0 if n < 0
    
    @training_set = []
    while n > @training_set.size
      @training_set << random_next(items_size) while n > @training_set.size
      @training_set.uniq!
    end
    @training_set
  end
  
  protected
    def random_next(n)
      self.items[rand(n)]
    end
  
end

class DataFrame
  include Training
end