# The University of California - Irvine has a great set of machine
# learning sample data sets.  Their data description pages have field
# label descriptors.  This class extracts them and returns a DataFrame
# with the labels of a data set. 

# Turns out, this isn't very useful.  So...oh well.
# By the way, the code I'm talking about is found here: http://archive.ics.uci.edu/ml/
# And to use this class:
# require 'lib/data_frame/labels_from_uci'
# df = LabelsFromUCI.data_frame 'http://archive.ics.uci.edu/ml/machine-learning-databases/communities/communities.names'
# df.import('http://archive.ics.uci.edu/ml/machine-learning-databases/communities/communities.data')

class LabelsFromUCI

  class << self
    def process(url)
      lfu = new(url)
      lfu.labels
    end
    
    def data_frame(url)
      lfu = new(url)
      DataFrame.new(lfu.labels)
    end
  end
  
  attr_reader :url, :contents, :labels
  
  def initialize(url)
    @url = url
    open(url) { |f| @contents = f.read }
    process_labels
  end
  
  protected
    def process_labels
      @labels = []
      @contents.each_line do |line|
        if line =~ label_re
          @labels << $1
        end
      end
    end
    
    def label_re
      /@attribute (\w+)/
    end
end