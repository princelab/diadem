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
            carbamidomethyl: true,
            oxidized_met: true,
            pyroglutamate_from_glutamine: true,
            element: :H,
            mass_number: 2,
            range: make_range[ start, stop, step ],
            degree: 3,
            header: true,
            num_isotopomers: 5,
            zero: false,
            remove_duplicates: true,
          } )
                              
          parser = OptionParser.new do |op|
            prog = File.basename($0)
            op.banner =  "usage: #{prog} <AASEQ> ..." 
            op.separator "   or: #{prog} <aaseqs>.csv" 
            op.separator "       <aaseqs>.csv is a single column of AA sequences"
            op.separator "        (csv file should have no header; blank lines will be ignored)"
            op.separator ""
            op.separator "output: tab delimited to stdout if AASEQ"
            op.separator "        <aaseqs>#{Diadem::Cubic::FILE_EXT} if csv input"
            op.separator ""
            op.separator "options:"
            op.on("-e", "--element <#{opt.element}>", "element with isotopic label") {|v| opt.element = v.to_sym }
            op.on("-m", "--mass-number <#{opt.mass_number}>", Integer, "the labeled element mass number") {|v| opt.mass_number = v }
            op.on("--[no-]carbamidomethyl", "default: carbamidomethyl = true") {|v| opt.carbamidomethyl = v }
            op.on("--range <start:stop:step>", "the underlying input values (#{[start, stop, step].join(':')})") {|v| opt.range = make_range[ *v.split(':') ] }
            op.on("--degree <#{opt.degree}>", Integer, "the degree polynomial") {|v| opt.degree = v }
            op.on("--num-isotopomers <#{opt.num_isotopomers}>", Integer, "the number of isotopomers to calculate") {|v| opt.num_isotopomers = v }
            op.on("--[no-]header", "print header line, default: true") {|v| opt.header = v }
            op.on("--return-zero-coeff", "return the 0th polyfit coefficient") {|v| opt.return_zero_coeff = v }
            op.on("--[no-]remove-duplicates", "disregard duplicate peptide entries, default: true") {|v| opt.remove_duplicates = v }
          end
          parser.parse!(argv)
          if argv.size == 0
            puts parser
            exit
          end
          [argv, opt]
        end
      end

    end
  end
end
