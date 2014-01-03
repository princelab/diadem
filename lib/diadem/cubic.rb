require 'diadem/cubic/commandline'
require 'diadem/calculator'
require 'csv'

module Diadem
  module Cubic
    
    Isotope = Struct.new(:element, :mass_number)
    Peptide = Struct.new(:aaseq, :isotope, :enrichments)
    Enrichment = Struct.new(:fraction, :distribution)

    MW_TO_NUM_ISOTOPES = {
      (0.0...2400.0) => 4,
      (2400.0..Float::INFINITY) => 5,
    }
  
    FILE_EXT = '.cubic.csv'
    class << self
      # returns the filename of the output if given a filename, or nil
      def run(argv)
        (argv, opt) = Diadem::Cubic::Commandline.parse(argv)
        opt.isotope = Diadem::Cubic::Isotope.new( opt.element, opt.mass_number )
        opt.delim = ","
        (out, aaseqs) = 
          if is_filename?(argv.first)
            arg = argv.first
            base = arg.chomp(File.extname(arg))
            [File.open(base + FILE_EXT, 'w'), CSV.read(arg).map(&:first)]
          else
            [$stdout, argv]
          end
        calc = Diadem::Calculator.new( *opt.isotope.values )

        num_isotopomers = opt.mw_to_num_isotopes.values.max

        if opt.header
          cats = %w(sequence mods formula mass n)
          isotopomers = *num_isotopomers.times.map {|n| "M#{n}" }
          cats.push(*isotopomers)
          isotopomers.each do |label|
            lowest_coeff = opt.return_zero_coeff ? 0 : 1
            (opt.degree).downto(lowest_coeff) do |coeff|
              cats << [label, "coeff", coeff].join("_")
            end
          end
          out.puts cats.join(opt.delim)
        end

        aaseqs.compact!  # ignore blank lines
        aaseqs.uniq! if opt.remove_duplicates

        aaseqs.each do |aaseq|
          # we cannot ensure the base 0% has been included in the range, so
          # calculate it separately
          mods = []
          if opt.carbamidomethyl
            mods << Diadem::Calculator::Modification::CARBAMIDOMETHYL
          end
          if opt.oxidized_met
            mods << Diadem::Calculator::Modification::OXIDIZED_METHIONINE
          end
          if opt.pyroglutamate_from_glutamine
            mods << Diadem::Calculator::Modification::PYROGLUTAMATE_Q
          end

          (distributions, info) = calc.calculate_isotope_distributions(aaseq, opt.range.dup, mods: mods, mw_to_num_isotopes: opt.mw_to_num_isotopes)
          polynomials = Diadem::Calculator.distributions_to_polynomials(opt.range.to_a, distributions, info.num_isotopes_used, opt.degree)

          zero_pct_dist = 
            if opt.range.first == 0.0
              distributions.first
            else
              (dists, info) = calc.calculate_isotope_distributions(aaseq, [0.0])
              zero_pct_dist = dists.first
            end

          modinfo = info.mods.map {|match, mod| "#{match}:#{mod.sign}#{mod.diff_formula}" }.join(' ')
          line = [aaseq, modinfo, info.formula, info.formula.mass.round(6), info.penetration]
          line.push *zero_pct_dist.intensities[0,info.num_isotopes_used].map {|v| v.round(6) }
          (num_isotopomers - info.num_isotopes_used).times { line.push(nil) }
          polynomials.each do |coeffs|
            rev_coeffs = coeffs.reverse
            rev_coeffs.pop unless opt.return_zero_coeff
            line.push *rev_coeffs
          end
          out.puts line.join(opt.delim)
        end
        if out.respond_to?(:path)
          out.close
          out.path
        end
      end

      def is_filename?(arg)
        arg.include?('.') 
      end
    end
  end

end
