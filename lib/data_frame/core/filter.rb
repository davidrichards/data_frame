module DF #:nodoc:
  module Filter #:nodoc:
    
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
end

class DataFrame
  include DF::Filter
end