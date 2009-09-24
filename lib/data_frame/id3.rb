module DF #:nodoc:
  # Uses Ilya Grigorik's ID3 decision_tree gem.  Installs it if you don't have it.
  module ID3
    begin
      gem 'decisiontree'
      require 'decisiontree'
    rescue
      `sudo gem install decisiontree`
      gem 'decisiontree'
      require 'decisiontree'
    end

    def create_id3(dependent_column, opts={})
      # Need to put the dependent column in the last column
      # Probably have other pre processing as well.
      default = opts.fetch(:default, 1)
      @id3 = DecisionTree::ID3Tree.new(self.labels, self.training_data, default, :discrete)
      # ...
    end

    def id3
    end
  end
end

class DataFrame
  include DF::ID3
end