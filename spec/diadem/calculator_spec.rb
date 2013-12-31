require 'spec_helper'
require 'csv'

require 'diadem/calculator'

Isotope = Struct.new(:element, :mass_number)
Peptide = Struct.new(:aaseq, :isotope, :enrichments)
Enrichment = Struct.new(:fraction, :distribution)

# returns [fractions, [array_of_intensity1s, array_of_intensity2s ...]
def transpose_enrichments(peptide)
  fractions = peptide.enrichments.map(&:fraction)
  [fractions, peptide.enrichments.map(&:distribution).transpose]
end


describe 'calculating enrichments' do

  it 'makes distributions' do

    rows = CSV.read(TESTFILES + "/old_output_format/output_tabular.csv")
    mida_peptides = []
    read_enrichments = false
    rows.each_with_index do |row,i|
      if row.compact.size == 0
        read_enrichments = false
      elsif read_enrichments
        row.map!(&:to_f)
        mida_peptides.last.enrichments << Enrichment.new( row[0], row[1..-1] )
      elsif row[0] =~ /\AIsotope=/
        (mass_number_s, element_s) = row[0].split('=').last.each_char.to_a
        isotope = Isotope.new(element_s.to_sym, mass_number_s.to_i)
        aaseq = rows[i-1].first.split(/\s+/).first
        mida_peptides << Peptide.new(aaseq, isotope, [])
        read_enrichments = true
      end
    end
    #mida_peptides.reject! {|me| me.aaseq.include?('m') }

    [true, false].each do |round|
      my_peptides = mida_peptides.map do |mida_peptide|

        (element, mass_number) = mida_peptide.isotope.values

        calc = Diadem::Calculator.new(element, mass_number, Diadem::Enrichment::AA_TABLE, Mspire::Isotope::BY_ELEMENT, round)
        fractions = mida_peptide.enrichments.map(&:fraction)
        (distributions, info) = calc.calculate_isotope_distributions(mida_peptide.aaseq, fractions)

        my_peptide = Peptide.new( mida_peptide.aaseq, mida_peptide.isotope )
        my_peptide.enrichments = distributions.zip(fractions).map do |distribution, fractions|
          Enrichment.new( fractions, distribution.resize!(7) )
        end
        my_peptide
      end

      $PLOT = false
      if $PLOT
        require 'gnuplot'
        mida_peptides.zip(my_peptides) do |mida, mine|
          plottype = 'png'
          base = mida.aaseq + "-ROUND:#{round}"
          plotfile = base + ".#{plottype}"
          mi = mida.isotope

          Gnuplot.open do |gp|
            Gnuplot::Plot.new(gp) do |plot|

              plot.title [mida.aaseq, "el:#{mi.element}", "massnum:#{mi.mass_number}", "round:#{round}"].join(" ")
              plot.terminal plottype
              plot.output plotfile
              plot.xlabel "label fraction"
              plot.ylabel "relative intensity"
              plot.yrange "[0:0.5]"

              plot.data = []

              mida_fracs_and_int_ars = transpose_enrichments(mida)

              byu_fracs_and_ints_ars = transpose_enrichments(mine)
              [:mida, mida_fracs_and_int_ars, :byu, byu_fracs_and_ints_ars].each_slice(2) do |name, (fracs, int_ars)|
                int_ars.each_with_index do |ints, mnum|
                  plot.data << Gnuplot::DataSet.new( [fracs, ints] ) {|ds| ds.title = "#{name}-M#{mnum}"; ds.with = "lines" }
                end
              end
            end
          end
        end
      end

    end
  end
end


