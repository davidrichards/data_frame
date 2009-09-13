require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "ARFF" do
  before do
    @df = DataFrame.from_csv(File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'basic.csv')))
  end
  
  it "should allow a data frame to be expressed as an arff-formatted file" do
    @df.to_arff.should eql(basic_arff)
  end
  
  it "should add a to_csv method" do
    @df.to_csv.should eql(%{x,y,month,day,ffmc,dmc,dc,isi,temp,rh,wind,rain,area
7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
})
  end
  
  it "should allow a non-header export for to_csv" do
    @df.to_csv(false).should eql(%{7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
})
  end
end

def basic_arff
  %[@relation basic

@attribute x {7}
@attribute y {4,5}
@attribute month {mar,oct}
@attribute day {fri,tue}
@attribute ffmc {86.2,90.6}
@attribute dmc {26.2,35.4}
@attribute dc {94.3,669.1}
@attribute isi {5.1,6.7}
@attribute temp {8.2,18}
@attribute rh {33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51}
@attribute wind {0.9,6.7}
@attribute rain {0}
@attribute area {0}

@data   
7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
7,4,oct,tue,90.6,35.4,669.1,6.7,18,33,0.9,0,0
]
end