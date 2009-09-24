module DF #:nodoc:
  # Turns Data Frame into a feeder for Carl Youngblood's Simple Bayesian classifier.  
  # Will install it if you don't have it.
  module SBN
    begin
      gem 'sbn'
      require 'sbn'
    rescue
      `sudo gem install sbn`
      gem 'sbn'
      require 'sbn'
    end
  end
end

class DataFrame
  include DF::SBN
end
