require "diadem/version"
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

  module Enrichment
    AA_TABLE = {
      'A' => 4,
      'R' => 3.43,
      'N' => 1.89,
      'D' => 1.89,
      'C' => 1.62,
      'E' => 3.95,
      'Q' => 3.95,
      'G' => 2.06,
      'H' => 2.88,
      'I' => 1,
      'L' => 0.6,
      'K' => 0.54,
      'M' => 1.12,
      'F' => 0.32,
      'P' => 2.59,
      'S' => 2.61,
      'T' => 0.2,
      'Y' => 0.42,
      'W' => 0.0,
      'V' => 0.56,
    }
  end

  class Calculator

    # returns spectra objects.  The isotope_table handed in will not be altered
    def initialize(element=:H, mass_number=2, penetration_table=Enrichment::AA_TABLE, isotope_table=Mspire::Isotope::BY_ELEMENT)
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
      puts "#{@element}: #{formula[@element]}"
      puts "penetration: #{penetration}"
      puts "fraction_penetration: #{penetration.to_f / formula[@element]}"
      penetration.to_f / formula[@element]
    end
    
    def plot_enrichments(aaseq, enrichments, normalize_type=:total )
      pct_cutoff = 0.1

      formula = Mspire::MolecularFormula.from_aaseq(aaseq)

      max_pen_frac = max_penetration_fraction(aaseq, formula)

      isotopes = @isotope_table[@element]

      enrichments.map do |enrich_frac|
        effective_fraction = max_pen_frac * enrich_frac
        @isotope_table[@element] = Diadem.enrich_isotope(isotopes, @mass_number, effective_fraction)
        spectrum = formula.isotope_distribution_spectrum(normalize_type, pct_cutoff, @isotope_table)
      end
    end
  end
end



