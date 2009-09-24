module DF #:nodoc:
  # Turns Data Frame into a feeder for Red Davis' MLP classifier.  
  # Will install it if you don't have it.
  module MLP
    begin
      gem 'reddavis-mlp'
      require 'mlp'
    rescue
      `sudo gem install reddavis-mlp`
      gem 'reddavis-mlp'
      require 'mlp'
    end
  end
end

class DataFrame
  include DF::MLP
end