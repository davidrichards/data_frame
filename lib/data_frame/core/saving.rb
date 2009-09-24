module DF #:nodoc:
  module Saving #:nodoc:

    # Saves a data frame as CSV.  
    # Examples:
    # df.save('/tmp/some_filename.csv')
    # df.save('/tmp/some_filename.csv', :include_header => false) # No header information is saved
    # df.save('/tmp/some_filename.csv', :only => [:list, :of, :columns])
    # df.save('/tmp/some_filename.csv', :subset => [:list, :of, :columns])
    # df.save('/tmp/some_filename.csv', 
    #   :filter => {:column_name => :category_value, 
    #     :another_column_name => (range..values)}) # Filter by category
    def save(filename, opts={})

      df = self
      df = df.subset_from_columns(*Array(opts[:only])) if opts[:only]
      df = df.subset_from_columns(*Array(opts[:subset])) if opts[:subset]
      df = df.filter_by_category(opts[:filter]) if opts[:filter]
      df = df.filter_by_category(opts[:filter_by_category]) if opts[:filter_by_category]

      File.open(filename, "w") { |f| f.write df.to_csv(opts.fetch(:include_header, true)) }
    end

  end
end

class DataFrame
  include DF::Saving
end
