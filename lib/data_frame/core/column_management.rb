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
    
    # Duplicates a column.  This is useful when creating a related column, such as values by category.
    def duplicate!(column_name)
      return false unless self.labels.include?(column_name)
      i = 1
      i += 1 while self.labels.include?(new_column_name(column_name, i))
      self.append!(new_column_name(column_name, i), self.render_column(column_name))
    end
    
    def new_column_name(column_name, i)
      (column_name.to_s + i.to_s).to_sym
    end
    protected :new_column_name
    
  end
end

class DataFrame
  include DF::ColumnManagement
end