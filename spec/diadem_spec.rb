require 'spec_helper'

require 'diadem'
require 'gnuplot'

describe 'calculating enrichement' do
  it 'makes spectra' do
    element = :H
    mass_number = 2
    aaseq = 'AAI'
    calc = Diadem::Calculator.new(element, mass_number)
    enrichments = (0..1).step(0.1).to_a.reverse.map {|v| v.round(1) }
    spectra = calc.plot_enrichments(aaseq, enrichments)

    spectra.zip(enrichments) do |spectrum, enrich_frac|

      base = "enrichment_#{enrich_frac}"
      outfile = base + ".dat"
      File.open(outfile, 'w') do |gp|
        Gnuplot::Plot.new(gp) do |plot|


          plot.title [aaseq, "element: #{element}", "mass_num: #{mass_number}", "enrich_frac: #{enrich_frac}", "max_penetration: ", calc.max_penetration_fraction(aaseq, Mspire::MolecularFormula.from_aaseq(aaseq)) ].join(" ")
          plot.terminal "svg"
          plot.output base + ".svg"
          plot.xrange "[273:290]"
          plot.yrange "[0:0.9]"

          plot.data = [
            Gnuplot::DataSet.new( spectrum.data_arrays ) {|ds| ds.with = "impulses" }
          ]
        end
      end
      system "gnuplot #{outfile}"
      File.unlink(outfile)
    end
  end
end
