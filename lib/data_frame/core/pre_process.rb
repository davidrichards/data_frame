module DF #:nodoc:
  module PreProcess #:nodoc:
    # A weird name.  This creates a column for every category in a column
    # and marks each row by its value 
    def j_binary_ize!(*columns)
      # Allows to mix a hash with the columns.
      options = columns.find_all {|e| e.is_a?(Hash)}.inject({}) {|h, e| h.merge!(e)}
      columns.delete_if {|e| e.is_a?(Hash)}

      # Generates new columns
      columns.each do |col|
        values = render_column(col.to_underscore_sym)
        values.categories.each do |category|
          full_name = (col.to_s + "_" + category.to_s).to_sym
          if options[:allow_overlap]
            category_map = values.inject([]) do |list, e|
              list << values.all_categories(e)
            end
            self.append!(full_name, category_map.map{|e| e.include?(category)})
          else
            self.append!(full_name, values.category_map.map{|e| e == category})
          end
        end
      end
    end

    # Adds a column, numerical_column_name that shows the same data as a
    # nominal value, but as a number. 
    def numericize!(*columns)
      columns.each do |col|
        values = render_column(col.to_underscore_sym)
        categories = values.categories
        value_categories = values.map {|v| values.category(v)}

        i = 0
        category_map = value_categories.uniq.inject({}) do |h, c|
          h[c] = i
          i += 1
          h
        end

        blank = Array.new(category_map.size, 0)
        reverse_category_map = category_map.inject({}) {|h, e| h[e.last] = e.first; h}

        new_values = values.inject([]) do |list, val|
          a = blank.dup
          a[category_map[values.category(val)]] = 1
          list << a
        end

        new_name = "numerical #{col.to_s}".to_underscore_sym
        self.append!(new_name, new_values)
      end
    end
    
    def categorize!(*cs)
      store_range_hashes
      cs.each do |column|
        self.replace!(column, category_map_from_stored_range_hash(column))
      end
      restore_range_hashes
    end
    
  end
end

class DataFrame
  include DF::PreProcess
end