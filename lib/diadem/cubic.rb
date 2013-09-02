require 'diadem/cubic/commandline'
require 'diadem/calculator'
require 'csv'

module Diadem
  module Cubic
    FILE_EXT = '.cubic.csv'
    class << self
      def run(argv)
        (argv, opt) = Diadem::Cubic::Commandline.parse(argv)
        (out, aaseqs) = 
          if is_filename?(argv.first)
            arg = argv.first
            base = arg.chomp(File.extname(arg))
            [File.open(base + FILE_EXT, 'w'), CSV.read(arg).map(&:first)]
          else
            [$stdout, argv]
          end
        calc = Diadem::Calculator.new( opt.element, opt.mass_number )
        aaseqs.each do |aaseq|
          spectra = calc.calculate_isotope_distribution_spectrum(aaseq, opt.range)
        end
        p spectra
      end

      def is_filename?(arg)
        arg.include?('.') 
      end
    end
  end

end
