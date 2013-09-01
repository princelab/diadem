require 'spec_helper'

require 'diadem/cubic'

describe Diadem::Cubic do
  it 'works' do
    reply = Diadem::Cubic.run( TESTFILES + "/input.csv" )
    p reply
  end
end
