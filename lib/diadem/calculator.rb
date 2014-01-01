require 'matrix'

require "diadem/version"
require "diadem/enrichment"
require "diadem/distribution"
require 'mspire/molecular_formula'
require 'mspire/isotope/distribution'

module Diadem
  class Calculator
    # a match (a regex or a String of length 1) that indicates which amino
    # acid should be modified, diff_formula is an Mspire::MolecularFormula
    # object, gain  is whether the molecular formula is added or subtracted
    # (boolean, default true).  static is boolean, default true.  match_block
    # by default will merely return the thing being matched (which is good
    # behavior for static mods)
    Modification = Struct.new(:match, :diff_formula, :gain, :static, :match_block) do
      def initialize(*args, &_match_block)
        (_char, _formula, _gain, _static) = args
        _gain.nil? && ( _gain=true )
        _static.nil? && ( _static=true )
        _match_block.nil? && (_match_block=Diadem::Calculator::Modification::STATIC_MATCH_BLOCK)
        super(_char, _formula, _gain, _static, _match_block)
      end

      # the arithmetic sign as a symbol: :+ or :-
      def sign
        gain  ?  :+  :  :-
      end
    end

    class Modification
      VAR_MATCH_BLOCK = lambda(&:upcase)
      STATIC_MATCH_BLOCK = lambda {|match| match }

      MF = Mspire::MolecularFormula
      OXIDIZED_METHIONINE = Modification.new('m', MF['O'], true, false, &VAR_MATCH_BLOCK)
      PYROGLUTAMATE_Q = Modification.new('q', MF['NH3'], false, false, &VAR_MATCH_BLOCK)
      # aka methylcarboxamido
      CARBAMIDOMETHYL = Modification.new('C', MF['C2H3NO'])

      DEFAULT_STATIC_MODS = [CARBAMIDOMETHYL]
      DEFAULT_VAR_MODS = [OXIDIZED_METHIONINE, PYROGLUTAMATE_Q]
      DEFAULT_MODS = DEFAULT_STATIC_MODS + DEFAULT_VAR_MODS
    end


    Info = Struct.new(:orig_aaseq, :clean_aaseq, :formula, :penetration, :masses, :mods)

    class Polynomial < Array ; end

    class << self
      # from http://rosettacode.org/wiki/Polynomial_regression#Ruby.  Returns
      # a Polynomial object
      def polyfit(x, y, degree)
        x_data = x.map {|xi| (0..degree).map { |pow| (xi**pow).to_f } }

        mx = Matrix[*x_data]
        my = Matrix.column_vector(y)

        Diadem::Calculator::Polynomial.new( ((mx.t * mx).inv * mx.t * my).transpose.to_a[0] )
      end

      # returns new isotopes, properly enriched.
      def enrich_isotope(isotopes, mass_number, fraction=1.0)
        new_isotopes = isotopes.map(&:dup)
        leftover_fraction = 1.0 - fraction
        new_isotopes.each {|isot| isot.relative_abundance *= leftover_fraction }
        isot_to_enrich = new_isotopes.find {|isot| isot.mass_number == mass_number }
        isot_to_enrich.relative_abundance += fraction
        new_isotopes
      end

      # related intensities
      def distributions_to_polynomials(enrichments, distributions, num=5, degree=2)
        distributions.map {|dist| dist.intensities[0,num] }.transpose.each_with_index.map do |ar, m|
          polyfit(enrichments, ar, degree)
        end
      end
    end

    # returns spectra objects.  The isotope_table handed in will not be altered
    def initialize(element=:H, mass_number=2, penetration_table=Enrichment::AA_TABLE, isotope_table=Mspire::Isotope::BY_ELEMENT, round=false)
      @round = round
      @penetration_table, @element, @mass_number = penetration_table, element, mass_number
      @isotope_table = dup_isotope_table(isotope_table)
    end

    def dup_isotope_table(table)
      table.each.with_object({}) do |(key,val), new_table|
        new_table[key] = val.map {|obj| obj.dup }
      end
    end

    def max_penetration_fraction(aaseq, formula)
      penetration = aaseq.each_char.inject(0.0) do |sum, aa|
        sum + ( @penetration_table[aa] || 0.0 )
      end
      penetration = penetration.round if @round
      @info.penetration = penetration
      penetration.to_f / formula[@element]
    end

    # returns [formula_adjusted_for_mods, aaseq_with_no_mods]
    def calculate_formula(aaseq_with_mods, mods)
      mods.group_by(&:char).each do |modchar, mod|
        aaseq_with_mods.each_char do |char|
          if char == modchar
          end
        end
      end


      Mspire::MolecularFormula.from_aaseq(aaseq)
    end
    
    # Returns [distributions, info].  Interprets lowercase m as singly oxidized methionine.
    # Right now, uses first 4 peaks if peptide mass is < 2400 and 5 peaks of >
    # 2400 [this needs to be parameterized]
    def calculate_isotope_distributions(aaseq, enrichments, normalize_type: :total, mods: Diadem::Calculator::Modification::DEFAULT_MODS)
      @info = Info.new

      mf = Mspire::MolecularFormula
      aaseq_up = aaseq
      subtract_formula = mf.new
      add_formula = mf.new
      matched_mods = []
      mods.each do |mod|
        delta_formula = mod.gain ? add_formula : subtract_formula
        aaseq_up = aaseq_up.gsub(mod.match) do |match|
          matched_mods << [match, mod]
          delta_formula.add!(mod.diff_formula)
          mod.match_block.call(match)
        end
      end
      @info.mods = matched_mods

      formula = mf.from_aaseq(aaseq_up)
      formula += add_formula
      formula -= subtract_formula
      @info.formula = formula

      num_peaks_to_keep = ( formula.mass < 2400 ? 4 : 5 )

      max_pen_frac = max_penetration_fraction(aaseq_up, formula)

      orig_isotopes = @isotope_table[@element]

      distributions = enrichments.map do |enrich_frac|
        effective_fraction = max_pen_frac * enrich_frac
        @isotope_table[@element] = Diadem::Calculator.enrich_isotope(orig_isotopes, @mass_number, effective_fraction)
        spectrum = formula.isotope_distribution_spectrum(normalize: normalize_type, peak_cutoff: num_peaks_to_keep, isotope_table: @isotope_table)
        @isotope_table[@element] = orig_isotopes
        @info.masses = spectrum.mzs unless @info.masses
        Diadem::Distribution.new( spectrum.intensities )
      end
      [distributions, @info]
    end
  end
end



