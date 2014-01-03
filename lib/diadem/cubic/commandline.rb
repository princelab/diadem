require 'optparse'
require 'ostruct'

module Diadem
  module Cubic
    module Commandline

      class << self

        # "<start-m/z>:<end-m/z>[e]:num_isotopes,..." 'e' means exclude end
        # for the range. Uses Float(num) to cast.
        def range_string_to_range_hash(string)
          string.split(',').each_with_object({}) do |st, hash|
            (start_st, endval_st, num_isotopes_st) = st.split(':')
            if endval_st[-1] == 'e'
              endval_st = endval_st[0...-1]
              exclude_end = true
            else
              exclude_end = false
            end
            endval_st = "1e1000" if endval_st == "Infinity"
            hash[ Range.new(Float(start_st), Float(endval_st), exclude_end) ] = Integer(num_isotopes_st)
          end
        end

        def range_hash_to_range_string(hash)
          hash.map do |range, num_isotopes|
            [range.begin, "#{range.end}#{range.exclude_end? ? 'e' : ''}", num_isotopes].join(':')
          end.join(',')
        end
        
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
            zero: false,
            remove_duplicates: true,
            mw_to_num_isotopes: range_hash_to_range_string(Diadem::Cubic::MW_TO_NUM_ISOTOPES),
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
            op.on("--[no-]header", "print header line, default: true") {|v| opt.header = v }
            op.on("--return-zero-coeff", "return the 0th polyfit coefficient") {|v| opt.return_zero_coeff = v }
            op.on("--[no-]remove-duplicates", "disregard duplicate peptide entries, default: true") {|v| opt.remove_duplicates = v }
            op.on("--mw-to-num-isotopes", "<start-m/z>:<end-m/z>[e]:num_isotopes,...", "an 'e' will make the range exclude the end", "default: #{opt.mw_to_num_isotopes}") {|v| opt.mw_to_num_isotopes = v }
          end
          parser.parse!(argv)
          if argv.size == 0
            puts parser
            exit
          end

          opt.mw_to_num_isotopes = range_string_to_range_hash(opt.mw_to_num_isotopes)

          [argv, opt]
        end
      end

    end
  end
end
