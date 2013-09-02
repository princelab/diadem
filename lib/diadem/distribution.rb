
module Diadem
  class Distribution
    attr_accessor :intensities

    def initialize(intensities)
      @intensities = intensities
    end

    # returns self
    def resize!(num)
      newar = @intensities.dup
      to_pad = num - @intensities.size
      unless to_pad <= 0
        to_pad.times { newar << 0.0 }
      end
      @intensities.replace( newar[0,num] )
      self
    end
  end
end
