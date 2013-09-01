require 'diadem/cubic/commandline'

module Diadem
  module Cubic
    class << self
      def run(argv)
        (arg, opt) = Diadem::Cubic::Commandline.parse(argv)
        puts "LOOKING AT PARSER OUTPUT:"
        p arg
        p opt
      end
    end
  end

end
