require 'matrix'

require "diadem/version"
require "diadem/enrichment"
require "diadem/distribution"
require 'mspire/molecular_formula'
require 'mspire/isotope/distribution'

module Diadem
  class Calculator

    Info = Struct.new(:aaseq, :formula, :penetration, :masses)

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
    
    # Returns [distributions, info].  Interprets lowercase m as singly oxidized methionine.
    def calculate_isotope_distributions(aaseq, enrichments, normalize_type=:total, length=5)
      @info = OpenStruct.new
      pct_cutoff = nil

      num_oxidized = aaseq.each_char.count('m')
      aaseq_up = aaseq.upcase

      formula = Mspire::MolecularFormula.from_aaseq(aaseq_up)
      formula += Mspire::MolecularFormula.new( { O: num_oxidized } )
      @info.formula = formula

      max_pen_frac = max_penetration_fraction(aaseq_up, formula)

      orig_isotopes = @isotope_table[@element]

      distributions = enrichments.map do |enrich_frac|
        effective_fraction = max_pen_frac * enrich_frac
        @isotope_table[@element] = Diadem::Calculator.enrich_isotope(orig_isotopes, @mass_number, effective_fraction)
        spectrum = formula.isotope_distribution_spectrum(normalize_type, pct_cutoff, @isotope_table)
        @isotope_table[@element] = orig_isotopes
        @info.masses = spectrum.mzs unless @info.masses
        Diadem::Distribution.new( spectrum.intensities )
      end
      [distributions, @info]
    end
  end
end



