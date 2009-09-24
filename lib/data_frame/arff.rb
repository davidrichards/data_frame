module DF #:nodoc:
  # Turns a data frame into ARFF-formatted content.
  module ARFF

    # Used in arff, but generally useful.
    def to_csv(include_header=true)
      value = include_header ? self.labels.map{|e| e.to_s}.join(',') + "\n" : ''
      self.items.inject(value) do |list, e|
        list << e.map {|cell| cell.to_s}.join(',') + "\n"
      end
    end

    def to_arff
      arff_header + to_csv(false)
    end

    protected
      def arff_attributes
        container = defined?(Dictionary) ? Dictionary.new : Hash.new

        self.labels.inject(container) do |list, e|
          list[e] = self.render_column(e).categories
        end
      end

      def arff_formatted_attributes
        self.labels.inject('') do |str, e|
          val = "{" + self.render_column(e).categories.map{|x| x.to_s}.join(',') + "}"
          str << "@attribute #{e} #{val}\n"
        end
      end

      def arff_relation
        self.name ? self.name.to_underscore_sym.to_s : 'unamed_relation'
      end

      def arff_header
        %[@relation #{arff_relation}

#{arff_formatted_attributes}
@data   
]
      end

      alias :arff_items :to_csv
  end
  
end

class DataFrame
  include DF::ARFF
end