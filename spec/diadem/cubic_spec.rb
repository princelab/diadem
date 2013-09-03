require 'spec_helper'
require 'csv'

require 'diadem/cubic'

describe Diadem::Cubic do
  specify 'using an input file' do
    filename = Diadem::Cubic.run( [TESTFILES + "/input.csv"], )
    File.basename(filename).should == 'input.cubic.csv' 
    rows = CSV.read(filename)
    rows.first.should == %w(sequence mods formula mass n M0 M1 M2 M3 M4 M0_coeff_3 M0_coeff_2 M0_coeff_1 M0_coeff_0 M1_coeff_3 M1_coeff_2 M1_coeff_1 M1_coeff_0 M2_coeff_3 M2_coeff_2 M2_coeff_1 M2_coeff_0 M3_coeff_3 M3_coeff_2 M3_coeff_1 M3_coeff_0 M4_coeff_3 M4_coeff_2 M4_coeff_1 M4_coeff_0)
    rows.size.should == 4
    lrow = rows.last
    # these are verified
    lrow[0,10].should == ["NEVHCmLGQSTCEMIR", "C:+C2H3NO C:+C2H3NO m:+O", "C77H129N25O28S4", "1979.832173", "32.56", "0.298777", "0.293168", "0.213061", "0.114555", "0.051392"]
    # the below values are not verified for complete accuracy, but are frozen.
    # I *have* verified that my polyfit gives exactly the same as numpy.polyfit
    # I *have* verified that my fits give nearly the identical result when the
    # formula is used to calculate the function and compared with the raw
    # data.
    coeff_exp = ["-392.23934817385657", "96.69007230820951", "-8.611345775533028", "0.2941872043446288", "274.6030329923823", "-32.519634396959496", "-1.9819130901305437", "0.3015660872075071", "349.4058191339298", "-74.1471126522828", "2.8594996757768354", "0.2129971981087685", "101.51558561078951", "-45.23875117790308", "3.95095594421288", "0.1114045333664326", "-125.24493326823091", "0.15596911712410133", "2.5230711874760186", "0.04912040472741169"]
    lrow[10..-1].zip( coeff_exp )  do |mine, csv|
      mine.to_f.should be_within(1e-5).of(csv.to_f)
    end
  end
end
