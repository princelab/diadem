require 'spec_helper'
require 'csv'

require 'diadem/cubic'

describe Diadem::Cubic do
  specify 'using an input file' do
    filename = Diadem::Cubic.run( [TESTFILES + "/input.csv"], )
    File.basename(filename).should == 'input.cubic.csv' 
    rows = CSV.read(filename)
    rows.first.should == %w(sequence mods formula mass n M0 M1 M2 M3 M4 M0_coeff_3 M0_coeff_2 M0_coeff_1 M1_coeff_3 M1_coeff_2 M1_coeff_1 M2_coeff_3 M2_coeff_2 M2_coeff_1 M3_coeff_3 M3_coeff_2 M3_coeff_1 M4_coeff_3 M4_coeff_2 M4_coeff_1)
    rows.size.should == 4
    lrow = rows.last
    # these are verified
    lrow[0,10].should == ["qEVHCmLGQSTCEMIR", "C:+C2H3NO C:+C2H3NO m:+O q:-H3N", "C78H128N24O28S4", "1976.821274", "34.620000000000005", "0.289882", "0.292743", "0.215357", "0.117551", "0.053498"]
    # the below values are not verified for complete accuracy, but are frozen.
    # I *have* verified that my polyfit gives exactly the same as numpy.polyfit
    # I *have* verified that my fits give nearly the identical result when the
    # formula is used to calculate the function and compared with the raw
    # data.
coeff_exp = ["-421.06267678409387", "101.55583060246754", "-8.74184647393767", "255.13376040316183", "-26.207563393269137", "-2.5009206278495983", "393.62982958471537", "-79.40850743514103", "2.7886588615718955", "149.4201526179288", "-54.33441042414497", "4.230023348103629", "-115.19983206905863", "-4.686811308294118", "2.826941989880497"]
    lrow[10..-1].zip( coeff_exp )  do |mine, csv|
      mine.to_f.should be_within(1e-5).of(csv.to_f)
    end
  end
end
