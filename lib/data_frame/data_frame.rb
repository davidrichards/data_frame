# This allows me to have named columns and optionally named rows in a
# data frame, to work calculations (usually on the columns), to
# transpose the matrix and store the transposed matrix until the object
# is tainted. 
class DataFrame
  
  def inspect
    "DataFrame rows: #{self.rows.size} labels: #{self.labels.inspect}"
  end
  
  # The labels of the data items
  attr_reader :labels
  alias :variables :labels
  
  # The items stored in the frame
  attr_reader :items
  
  # An optional name, useful for arff files
  attr_accessor :name
  
  def initialize(*labels)
    labels = labels.first if labels.size == 1 and labels.first.is_a?(Array)
    @labels = labels.map {|e| e.to_underscore_sym }
    @items = TransposableArray.new
  end
  
  def row_labels
    @row_labels ||= []
  end
  
  def row_labels=(ary)
    raise ArgumentError, "Row labels must be an array" unless ary.is_a?(Array)
    @row_labels = ary
  end
  
  # The rows as an array of arrays, an alias for items.
  alias :rows :items
  
  def render_row(sym)
    i = self.row_labels.index(sym)
    return nil unless i
    @items[i]
  end
  
  # Return the column, given its name
  def render_column(sym)
    i = @labels.index(sym.to_underscore_sym)
    return nil unless i
    @items.transpose[i]
  end
  
  # The columns as a Dictionary or Hash
  # This is cached, call columns(true) to reset the cache.
  def columns(reset=false)
    @columns = nil if reset
    return @columns if @columns
    
    container = defined?(Dictionary) ? Dictionary.new : Hash.new
    i = 0
    
    @columns = @items.transpose.inject(container) do |cont, col|
      cont[@labels[i]] = col
      i += 1
      cont
    end
  end
  alias :to_hash :columns
  alias :to_dictionary :columns
  
  def method_missing(sym, *args, &block)
    if self.labels.include?(sym)
      render_column(sym)
    elsif self.row_labels.include?(sym)
      render_row(sym)
    elsif @items.respond_to?(sym)
      @items.send(sym, *args, &block)
    else
      super
    end
  end
  
  protected
  
    def validate_column(column)
      column = column.to_sym
      raise ArgumentError, "Must provide the name of an existing column.  Provided #{column.inspect}, needed to provide one of #{self.labels.inspect}" unless self.labels.include?(column)
      column
    end
    
    def infer_class(obj)
      obj = obj.to_s.classify.constantize if obj.is_a?(Symbol)
      obj = obj.classify.constantize if obj.is_a?(String)
      obj
    end
    
    def cast_row(row, as)
      if as == Hash
        obj = {}
        self.labels.each_with_index do |label, i|
          obj[label] = row[i]
        end
        obj
      elsif as == OpenStruct
        obj = OpenStruct.new
        self.labels.each_with_index do |label, i|
          obj.table[label] = row[i]
        end
        obj
      elsif as == Array
        row
      else
        as.new(*row)
      end
    end
end