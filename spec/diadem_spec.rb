require 'spec_helper'

require 'diadem'
require 'gnuplot'

describe 'calculating enrichement' do
  it 'makes spectra' do
    element = :H
    mass_number = 2
    aaseq = 'AAI'
    #aaseq = 'ELENLAAMDLELQK'
    calc = Diadem::Calculator.new(element, mass_number)
    enrichments = (0..1).step(0.1).map {|v| v.round(1) }
    spectra = calc.plot_enrichments(aaseq, enrichments)

    max_penetration = calc.max_penetration_fraction(aaseq, Mspire::MolecularFormula.from_aaseq(aaseq)).round(2)

    lo_x = spectra.last.mzs.first.floor
    hi_x = spectra.last.mzs.last.ceil
    hi_y = spectra.first.intensities.first

    spectra.zip(enrichments) do |spectrum, enrich_frac|

      base = "#{aaseq}_enrichment_#{enrich_frac}"
      outfile = base + ".dat"
      svgfile = base + ".svg"
      File.open(outfile, 'w') do |gp|
        Gnuplot::Plot.new(gp) do |plot|

          plot.title [aaseq, "el:#{element}", "massnum:#{mass_number}", "enrich:#{enrich_frac}", "max_penetration:#{max_penetration}",  ].join(", ")
          plot.terminal "svg"
          plot.output svgfile
          plot.xrange "[#{lo_x}:#{hi_x}]"
          plot.yrange "[0:#{hi_y}]"
          plot.xlabel "mass"
          plot.ylabel "relative intensity"

          plot.data = [
            Gnuplot::DataSet.new( spectrum.data_arrays ) {|ds| ds.with = "impulses" }
          ]
        end
      end
      system "gnuplot #{outfile}"
      system "svg_to_pxx.rb -b white -p -d 90 #{svgfile}"
      File.unlink(outfile)
      File.unlink(svgfile)
    end
  end
end
