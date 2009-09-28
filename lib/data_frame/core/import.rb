module DF #:nodoc:
  module Import #:nodoc:
    
    module InferCSV #:nodoc:

      protected
        def default_csv_opts; {:converters => :all}; end

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
          labels = opts.fetch(:headers, true) ? table.shift : []
          while table.last.empty?
            table.pop
          end
          [labels, table]
        end

    end # InferCSV

    module ClassMethods #:nodoc:

      include InferCSV

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
        name = infer_name_from_contents(obj, opts)
        return nil unless labels and table
        df = new(*labels)
        df.import(table)
        df.name = name
        df
      end

      protected

        # Only works for names sources, urls and files
        def infer_name_from_contents(obj, opts={})
          begin
            File.split(obj).last.split('.')[0..-2].join('.').titleize
          rescue
            nil
          end
        end

    end # Class Methods
    
    module InstanceMethods #:nodoc:

      include InferCSV
      
      def add_item(item)
        self.items << item
      end
      alias :add :add_item

      # Loads a batch of rows.  Expects an array of arrays, else you don't
      # know what you have. 
      def import(rows)
        case rows
        when Array
          import_array(rows)
        when String
          labels, table = infer_csv_contents(rows, :headers => false)
          import(table)
        else
          raise ArgumentError, "Don't know how to import data from #{rows.class}"
        end
        true
      end
      
      protected
        # Imports a table as an array of arrays.  
        # If the array is one-dimensional and there is more than one label, it
        # imports only one row. 
        def import_array(rows)
          raise ArgumentError, "Can only work with arrays" unless rows.is_a?(Array)
          if self.labels.size > 1 and rows.dimensions == 1
            self.add_item(rows)
          else
            # self.items = self.items + rows
            rows.each do |row|
              self.add_item(row)
            end
          end
        end
      
    end # Instance Methods
    
  end
end

class DataFrame
  include DF::Import::InstanceMethods
  extend DF::Import::ClassMethods
end
