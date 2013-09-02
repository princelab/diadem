require 'spec_helper'
require 'csv'

require 'diadem/cubic'

describe Diadem::Cubic do
  specify 'using an input file' do
    filename = Diadem::Cubic.run( [TESTFILES + "/input.csv"], )
    File.basename(filename).should == 'input.cubic.csv' 
    rows = CSV.read(filename)
    rows.first.should == ["sequence", "formula", "mass", "n", "M0", "M1", "M2", "M3", "M4", "M0_coeff_3", "M0_coeff_2", "M0_coeff_1", "M0_coeff_0", "M1_coeff_3", "M1_coeff_2", "M1_coeff_1", "M1_coeff_0", "M2_coeff_3", "M2_coeff_2", "M2_coeff_1", "M2_coeff_0", "M3_coeff_3", "M3_coeff_2", "M3_coeff_1", "M3_coeff_0", "M4_coeff_3", "M4_coeff_2", "M4_coeff_1", "M4_coeff_0"]
    rows.size.should == 6
    lrow = rows.last
    lrow[0,9].should == ["LQAEIFQAR", "C48H78N14O14", "1074.582193", "25.2", "0.543105", "0.317502", "0.106855", "0.026303", "0.005212"]
    lrow[9..-1].zip ["-447.39225715942405", "122.35571856857436", "-12.765068190233155", "0.5392206197899442", "606.7546810461529", "-112.71167343618981", "3.3370473783192747", "0.327093550347666", "213.73190245134947", "-76.02100060782047", "6.54710764369834", "0.1024394497988815", "-214.6888240877197", "13.902763266709457", "2.737361999093846", "0.022889276772156963", "-195.49280108857874", "33.412548779214426", "0.32217019672618874", "0.0058432338018233766"] do |mine, csv|
      mine.to_f.should be_within(1e-5).of(csv.to_f)
    end
  end
end
