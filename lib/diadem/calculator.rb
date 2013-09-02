require "diadem/version"
require "diadem/enrichment"
require 'mspire/molecular_formula'
require 'mspire/isotope/distribution'

module Diadem

  # returns new isotopes, properly enriched.
  def self.enrich_isotope(isotopes, mass_number, fraction=1.0)
    new_isotopes = isotopes.map(&:dup)
    leftover_fraction = 1.0 - fraction
    new_isotopes.each {|isot| isot.relative_abundance *= leftover_fraction }
    isot_to_enrich = new_isotopes.find {|isot| isot.mass_number == mass_number }
    isot_to_enrich.relative_abundance += fraction
    new_isotopes
  end

  class Calculator

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
      penetration.to_f / formula[@element]
    end
    
    # interprets lowercase m as singly oxidized methionine
    def calculate_isotope_distribution_spectrum(aaseq, enrichments, normalize_type=:total )
      pct_cutoff = nil

      num_oxidized = aaseq.each_char.count('m')
      aaseq_up = aaseq.upcase

      formula = Mspire::MolecularFormula.from_aaseq(aaseq_up)
      p aaseq
      puts "BEFORE ox: "
      p formula
      formula += Mspire::MolecularFormula.new( { O: num_oxidized } )
      puts "AFTER ox: "
      p formula

      max_pen_frac = max_penetration_fraction(aaseq_up, formula)

      isotopes = @isotope_table[@element]

      enrichments.map do |enrich_frac|
        effective_fraction = max_pen_frac * enrich_frac
        @isotope_table[@element] = Diadem.enrich_isotope(isotopes, @mass_number, effective_fraction)
        formula.isotope_distribution_spectrum(normalize_type, pct_cutoff, @isotope_table)
      end
    end
  end
end



