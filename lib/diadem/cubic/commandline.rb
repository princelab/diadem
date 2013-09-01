require 'optparse'
require 'ostruct'

module Diadem
  module Cubic
    module Commandline

      class << self
        def parse(argv)
          opt = OpenStruct.new( { carbamidomethylation: true } )
                              
          parser = OptionParser.new do |op|
            prog = File.basename($0)
            op.banner =  "usage: #{prog} <AASEQ>" 
            op.separator "   or: #{prog} <aaseqs>.csv" 
            op.separator "     <aaseqs>.csv is a single column of AA sequences"
            op.separator "     (with no header)"
            op.separator "output: tab delimited to stdout if AASEQ"
            op.separator "        <aaseqs>.cubic.csv if csv input"
            op.separator ""
            op.separator "options:"
            op.on("--no-carbamidomethylation", "do not use this mod by default") { opt.carbamidomethylation = false } 
          end
          parser.parse!(argv)
        end
      end

    end
  end
end
