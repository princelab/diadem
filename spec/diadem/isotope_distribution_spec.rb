require 'spec_helper'

require 'diadem/isotope_distribution'

describe Diadem::IsotopeDistribution do
  before do
    @dists = 
      [[1,2,1], 1,
       [2, 1, 1], 2,
       [4], 6
    ].each_slice(2).map do |ints, start|
      Diadem::IsotopeDistribution.new( ints, start ).normalize!
    end
  end

  specify 'average with equal weights' do
    output = Diadem::IsotopeDistribution.average(@dists)
    [0.083, 0.333, 0.167, 0.083, 0.0, 0.333].zip(output.intensities) do |act, exp|
      act.should be_within(0.002).of(exp)
    end
    output.nucleon_start.should == 1
    output.nucleon_end.should == 6
  end

  specify 'average with unequal weights' do
    output = Diadem::IsotopeDistribution.average(@dists, [1,1,10])
    [0.021, 0.083, 0.042, 0.021, 0.0, 0.833].zip(output.intensities) do |act, exp|
      act.should be_within(0.002).of(exp)
    end
    output.nucleon_start.should == 1
    output.nucleon_end.should == 6
  end

  specify 'normalize!' do
    output = Diadem::IsotopeDistribution.new([2,2,2,2], 3).normalize!
    output.nucleon_start.should == 3
    output.intensities.should == [0.25, 0.25, 0.25, 0.25]
  end
end
