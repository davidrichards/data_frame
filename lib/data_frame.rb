require 'rubygems'
require 'activesupport'
require 'just_enumerable_stats'
require 'open-uri'
require 'fastercsv'
require 'ostruct'

# Use a Dictionary if available
begin
  require 'facets/dictionary'
rescue LoadError => e
  # Do nothing
end


Dir.glob("#{File.dirname(__FILE__)}/ext/*.rb").each { |file| require file }

$:.unshift(File.dirname(__FILE__))

require 'data_frame/callback_array'
require 'data_frame/transposable_array'

# This allows me to have named columns and optionally named rows in a
# data frame, to work calculations (usually on the columns), to
# transpose the matrix and store the transposed matrix until the object
# is tainted. 
class DataFrame
  
  class << self
    
    # This is the neatest part of this neat gem.
    # DataFrame.from_csv can be called in a lot of ways:
    # DataFrame.from_csv(csv_contents)
    # DataFrame.from_csv(filename)
    # DataFrame.from_csv(url)
    # If you need to define converters for FasterCSV, do it before calling
    # this method: 
    # FasterCSV::Converters[:special] = lambda{|f| f == 'foo' ? 'bar' : 'foo'}
    # DataFrame.from_csv('http://example.com/my_special_url.csv', :converters => :special)
    # This returns bar where 'foo' was found and 'foo' everywhere else.
    def from_csv(obj, opts={})
      labels, table = infer_csv_contents(obj, opts)
      return nil unless labels and table
      df = new(*labels)
      df.import(table)
      df
    end
    
    protected
      def infer_csv_contents(obj, opts={})
        contents = File.read(obj) if File.exist?(obj)
        begin
          open(obj) {|f| contents = f.read} unless contents
        rescue
          nil
        end
        contents ||= obj if obj.is_a?(String)
        return nil unless contents
        table = FCSV.parse(contents, default_csv_opts.merge(opts))
        labels = table.shift
        while table.last.empty?
          table.pop
        end
        [labels, table]
      end
      
      def default_csv_opts; {:converters => :all}; end
  end
  
  # Loads a batch of rows.  Expects an array of arrays, else you don't
  # know what you have. 
  def import(rows)
    rows.each do |row|
      self.add_item(row)
    end
  end
  
  def inspect
    "DataFrame rows: #{self.rows.size} labels: #{self.labels.inspect}"
  end
  
  # The labels of the data items
  attr_reader :labels
  alias :variables :labels
  
  # The items stored in the frame
  attr_reader :items
  
  def initialize(*labels)
    @labels = labels.map {|e| e.to_underscore_sym }
    @items = TransposableArray.new
  end
  
  def add_item(item)
    self.items << item
  end
  alias :add :add_item
  
  def row_labels
    @row_labels ||= []
  end
  
  def row_labels=(ary)
    raise ArgumentError, "Row labels must be an array" unless ary.is_a?(Array)
    @row_labels = ary
  end
  
  def render_column(sym)
    i = @labels.index(sym)
    return nil unless i
    @items.transpose[i]
  end
  
  # The rows as an array of arrays, an alias for items.
  alias :rows :items
  
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
  
  def render_row(sym)
    i = self.row_labels.index(sym)
    return nil unless i
    @items[i]
  end
  
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
  
  def drop!(*labels)
    labels.each do |label|
      drop_one!(label)
    end
    self
  end
  
  def drop_one!(label)
    i = self.labels.index(label)
    return nil unless i
    self.items.each do |item|
      item.delete_at(i)
    end
    self.labels.delete_at(i)
    self
  end
  protected :drop_one!
  
  def replace!(column, values=nil, &block)
    column = validate_column(column)
    if not values
      values = self.send(column)
      values.map! {|e| block.call(e)}
    end
    replace_column(column, values)
    self
  end
  
  def replace_column(column, values)
    column = validate_column(column)
    index = self.labels.index(column)
    list = []
    self.items.each_with_index do |item, i|
      consolidated = item
      consolidated[index] = values[i]
      list << consolidated
    end
    @items = list.dup
  end
  protected :replace_column
  
  def validate_column(column)
    column = column.to_sym
    raise ArgumentError, "Must provide the name of an existing column.  Provided #{column.inspect}, needed to provide one of #{self.labels.inspect}" unless self.labels.include?(column)
    column
  end
  protected :validate_column
  
  # Takes a block to evaluate on each row.  The row can be converted into
  # an OpenStruct or a Hash for easier filter methods. Note, don't try this
  # with a hash or open struct unless you have facets available.
  def filter!(as=Array, &block)
    as = infer_class(as)
    items = []
    self.items.each do |row|
      value = block.call(cast_row(row, as))
      items << row if value
    end
    @items = items.dup
    self
  end
  
  def filter(as=Array, &block)
    new_data_frame = self.clone
    new_data_frame.filter!(as, &block)
  end
  
  def infer_class(obj)
    obj = obj.to_s.classify.constantize if obj.is_a?(Symbol)
    obj = obj.classify.constantize if obj.is_a?(String)
    obj
  end
  protected :infer_class
  
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
  protected :cast_row
  
  # Creates a new data frame, only with the specified columns.
  def subset_from_columns(*cols)
    new_labels = self.labels.inject([]) do |list, label|
      list << label if cols.include?(label)
      list
    end
    new_data_frame = DataFrame.new(*self.labels)
    new_data_frame.import(self.items)
    self.labels.each do |label|
      new_data_frame.drop!(label) unless new_labels.include?(label)
    end
    new_data_frame
  end
  
  # A weird name.  This creates a column for every category in a column
  # and marks each row by its value 
  def j_binary_ize!(*columns)
    columns.each do |col|
      values = render_column(col.to_underscore_sym)
      values.categories.each do |category|
        self.append!(category, values.map{|e| e == category ? true : false})
      end
    end
  end
  
  # Adds a unique column to the table
  def append!(column_name, value=nil)
    raise ArgumentError, "Can't have duplicate column names" if self.labels.include?(column_name)
    self.labels << column_name.to_underscore_sym
    if value.is_a?(Array)
      self.items.each_with_index do |item, i|
        item << value[i]
      end
    else
      self.items.each do |item|
        item << value
      end
    end
    # Because we are tainting the sub arrays, the TaintableArray doesn't know it's been changed.
    self.items.taint
  end
  
  def filter_by_category(hash)
    new_data_frame = self.dup
    hash.each do |key, value|
      key = key.to_underscore_sym
      next unless self.labels.include?(key)
      value = [value] unless value.is_a?(Array) or value.is_a?(Range)
      new_data_frame.filter!(:hash) {|row| value.include?(row[key])}
    end
    new_data_frame
  end

  def filter_by_category!(hash)
    hash.each do |key, value|
      key = key.to_underscore_sym
      next unless self.labels.include?(key)
      value = [value] unless value.is_a?(Array) or value.is_a?(Range)
      self.filter!(:hash) {|row| value.include?(row[key])}
    end
  end
    
end