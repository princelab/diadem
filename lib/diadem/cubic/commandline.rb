require 'optparse'
require 'ostruct'

module Diadem
  module Cubic
    module Commandline

      class << self
        def parse(argv)
          make_range = ->(start,stop,step) { Range.new(start, stop).step(step) }

          start = 0.0
          stop = 0.1
          step = 0.002
          opt = OpenStruct.new( {
            carbamidomethylation: true,
            oxidized_methionine: true,
            element: :H,
            mass_number: 2,
            range: make_range[ start, stop, step ],
            degree: 3,
            header: true,
            num_isotopomers: 5,
          } )
                              
          parser = OptionParser.new do |op|
            prog = File.basename($0)
            op.banner =  "usage: #{prog} <AASEQ> ..." 
            op.separator "   or: #{prog} <aaseqs>.csv" 
            op.separator "     <aaseqs>.csv is a single column of AA sequences"
            op.separator "     (with no header)"
            op.separator "output: tab delimited to stdout if AASEQ"
            op.separator "        <aaseqs>#{Diadem::Cubic::FILE_EXT} if csv input"
            op.separator ""
            op.separator "note: This is a very simplistic isotopomer calculator."
            op.separator "      A version using MzIdentML will be forthcoming"
            op.separator "      All lowercase 'm's are interpreted as oxidized methionine"
            op.separator ""
            op.separator "options:"
            op.on("--no-carbamidomethylation", "do not use this mod by default") { opt.carbamidomethylation = false } 
            op.on("-e", "--element <#{opt.element}>", "element with isotopic label") {|v| opt.element = v.to_sym }
            op.on("-m", "--mass-number <#{opt.mass_number}>", Integer, "the labeled element mass number") {|v| opt.mass_number = v }
            op.on("--range <start:stop:step>", "the underlying input values (default: #{[start, stop, step].join(':')})") do |v| 
              opt.range = make_range[ *v.split(':') ]
            end
            op.on("--degree <#{opt.degree}>", Integer, "the degree polynomial") {|v| opt.degree = v }
            op.on("--num-isotopomers <#{opt.num_isotopomers}>", Integer, "the number of isotopomers to calculate") {|v| opt.num_isotopomers = v }
            op.on("--no-header", "don't print a header line") {|v| opt.header = false }
          end
          parser.parse!(argv)
          [argv, opt]
        end
      end

    end
  end
end
