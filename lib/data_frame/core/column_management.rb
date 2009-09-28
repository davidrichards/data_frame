module DF #:nodoc:
  module ColumnManagement #:nodoc:
    
    def move_to_last!(orig_name)
      raise ArgumentError, "Column not found" unless self.labels.include?(orig_name)
      new_name = (orig_name.to_s + "_a_unique_name").to_sym
      self.append!(new_name, self.render_column(orig_name))
      self.drop!(orig_name)
      self.rename!(orig_name, new_name)
    end
    
    # In the order of alias: new_name, orig_name
    def rename!(new_name, orig_name)
      new_name = new_name.to_underscore_sym
      orig_name = orig_name.to_underscore_sym
      raise ArgumentError, "Column not found" unless self.labels.include?(orig_name)
      raise ArgumentError, "Cannot name #{orig_name} to #{new_name}, that column already exists." if self.labels.include?(new_name)
      i = self.labels.index(orig_name)
      self.labels[i] = new_name
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
      self.columns(true)
      # Because we are tainting the sub arrays, the TaintableArray doesn't know it's been changed.
      self.items.taint
    end
    
    def replace!(column, values=nil, &block)
      column = validate_column(column)
      if not values
        values = self.send(column)
        values.map! {|e| block.call(e)}
      end
      replace_column!(column, values)
      self
    end

    # Replace a single column with an array of values.
    # It is helpful to have the values the same size as the rest of the data
    # frame. 
    def replace_column!(column, values)
      store_range_hashes
      column = validate_column(column)
      index = self.labels.index(column)
      @items.each_with_index do |item, i|
        item[index] = values[i]
      end
      
      # Make sure we recalculate things after changing a column
      self.items.taint
      @columns = nil
      self.columns
      restore_range_hashes
      
      # Return the items
      @items
    end

    # Drop one or more columns
    def drop!(*labels)
      labels.each do |label|
        drop_one!(label)
      end
      self
    end

    # Drop a single column
    def drop_one!(label)
      i = self.labels.index(label)
      return nil unless i
      self.items.each do |item|
        item.delete_at(i)
      end
      self.labels.delete_at(i)
      self
    end
    
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
    
    # Duplicates a column, the values only.  This is useful when creating a related column, such as values by category.
    def duplicate!(column_name)
      return false unless self.labels.include?(column_name)
      i = 1
      i += 1 while self.labels.include?(new_column_name(column_name, i))
      self.append!(new_column_name(column_name, i), self.render_column(column_name).dup)
    end
    
    def new_column_name(column_name, i)
      (column_name.to_s + i.to_s).to_sym
    end
    protected :new_column_name
    
    protected
      def store_range_hashes
        @stored_range_hashes = self.labels.inject({}) do |h, label|
          h[label] = self.render_column(label).range_hash
          h
        end
        @stored_range_hashes = nil if @stored_range_hashes.all? {|k, v| v.nil?}
      end

      def restore_range_hashes
        return false unless @stored_range_hashes
        @stored_range_hashes.each do |label, range_hash|
          self.render_column(label).set_categories(range_hash) if range_hash
        end
        true
      end
      
      def category_map_from_stored_range_hash(column)
        self.render_column(column).set_categories(@stored_range_hashes[column]) if 
          @stored_range_hashes and @stored_range_hashes.keys.include?(column)
        self.render_column(column).category_map.dup
      end
    
    
  end
end

class DataFrame
  include DF::ColumnManagement
end