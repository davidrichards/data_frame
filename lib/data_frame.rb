require 'rubygems'
require 'activesupport'
require 'just_enumerable_stats'
require 'open-uri'
require 'fastercsv'

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
    def from_csv(obj, opts={})
      labels, table = infer_csv_contents(obj)
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
  
  # The labels of the data items
  attr_reader :labels
  
  # The items stored in the frame
  attr_reader :items
  
  def initialize(*labels)
    @labels = labels.map {|e| e.to_underscore_sym }
    @items = TransposableArray.new
  end
  
  def add_item(item)
    self.items << item
  end
  
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
  
end