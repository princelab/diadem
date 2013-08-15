require 'mspire/molecular_formula'
require 'mspire/isotope'
require 'fftw3'

module Diadem

  class IsotopeDistribution
    DEFAULT_ISOTOPE_TABLE = Mspire::Isotope::BY_ELEMENT

    # should always add up to 1
    attr_accessor :intensities
    # should be inclusive of last value
    attr_accessor :nucleon_start
    def initialize(intensities=[], nucleon_start=0)
      @intensities, @nucleon_start = intensities, nucleon_start
    end

    def nucleon_end
      nucleon_start + intensities.size - 1
    end

    class << self

      def from_formula(formula)
        Mspire::MolecularFormula[formula].isotope_distribution
      end

      # returns a new distribution, uses equal weights if none given
      def average(distributions, weights=nil)
        weights ||= Array.new(distributions.size, 1)
        min_nucleon_num = distributions.map(&:nucleon_start).min
        max_nucleon_num = distributions.map(&:nucleon_end).max

        new_intensity_arrays = distributions.zip(weights).map do |dist, weight|
          new_pcts = dist.intensities.dup
          right_pad = max_nucleon_num - dist.nucleon_end
          left_pad = dist.nucleon_start - min_nucleon_num
          [[right_pad, new_pcts.size], [left_pad, 0]].each do |pad, loc|
            new_pcts[loc,0] = Array.new(pad, 0.0)
          end
          new_pcts.map! {|v| v * weight }
          new_pcts
        end

        summed_intensities = new_intensity_arrays.transpose.map do |col|
          col.reduce(:+)
        end

        new_dist = self.new(summed_intensities, min_nucleon_num)
        new_dist.normalize!
      end
    end

    # normalizes intensity values and returns self
    def normalize!(normalize_to=1.0)
      sum = intensities.reduce(:+)
      intensities.map! {|v| (v.to_f/sum)*normalize_to }
      self
    end

  end

end
