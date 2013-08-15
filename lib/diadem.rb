require "diadem/version"
require 'mspire/isotope/distribution'

class Array
  def normalize!
    sum = self.reduce(:+)
    self.map! {|v| v.to_f/sum }
    self
  end
end

module Diadem

  class IsotopeDistribution
    attr_accessor :percentages
    # should be inclusive of last value
    attr_accessor :nucleon_range
    def initialize(percentages=[], nucleon_range=(0..0))
      @percentages, @nucleon_range = percentages, nucleon_range
    end
  end

  penetration_table = {
    A: 4,
    R: 3.43,
    N: 1.89,
    D: 1.89,
    C: 1.62,
    E: 3.95,
    Q: 3.95,
    G: 2.06,
    H: 2.88,
    I: 1,
    L: 0.6,
    K: 0.54,
    M: 1.12,
    F: 0.32,
    P: 2.59,
    S: 2.61,
    T: 0.2,
    Y: 0.42,
    W: 0.0,
    V: 0.56,
  }

  def plot_enrichment(aaseq, element, mass_number, enrichment_range, increment=0.01)

  end

  # it is assumed that each distribution adds up to 1
  def convolve_isotope_distributions(distributions, weights)
    min_nucleon_num = distributions.map {|dist| dist.nucleon_range.first }.min
    max_nucleon_num = distributions.map {|dist| dist.nucleon_range.last }.max

    new_pct_arrays = distributions.zip(weights).map do |distibution, weight|
      new_pcts = distribution.percentages.dup
      right_pad = max_nucleon_num - nucleon_range.last
      left_pad = nucleon_range.first - min_nucleon_num
      [[right_pad, new_pcts.size], [left_pad, 0]].each do |pad, loc|
        new_pcts[loc,0] = Array.new(pad, 0.0)
      end
      new_pcts.map! {|v| v * weight }
      new_pcts
    end

    new_pcts = new_pcts.transpose.map do |col|
      col.reduce(:+)
    end

    new_pcts.normalize!
  end

    
end
