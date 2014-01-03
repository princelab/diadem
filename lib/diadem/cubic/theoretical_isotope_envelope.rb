
module Diadem
  module Cubic
    class TheoreticalIsotopeEnvelope
      attr_reader :molecular_formula
      def initialize(molecular_formula)
      end
    end

    # a (peptide+mods) that has an associated isotope envelope
    class PeptideIsotopeEnvelope
      attr_accessor :aaseq
      attr_accessor :mods
      attr_accessor :isotope_envelope

      def initialize(aaseq, mods=[])
        @aaseq = aaseq
        @mods = mods
      end

      def from_aaseq(aaseq, mods=[])

    end
  end
end
