require 'rubygems'
require 'activesupport'
require 'just_enumerable_stats'
require 'open-uri'
require 'fastercsv'
require 'ostruct'

# Use a Dictionary if available
begin
  require 'facets/dictionary'
rescue LoadError => e
  # Do nothing
end


Dir.glob("#{File.dirname(__FILE__)}/ext/*.rb").each { |file| require file }

$:.unshift(File.dirname(__FILE__))

require 'data_frame/callback_array'
require 'data_frame/transposable_array'
require 'data_frame/parameter_capture'
require 'data_frame/data_frame'
require 'data_frame/model'

Dir.glob("#{File.dirname(__FILE__)}/data_frame/core/*.rb").each { |file| require file }
