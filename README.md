# Diadem

Tools for performing mass isotopomer distribution analysis (MIDA).  Basically,
this is dynamic isotope analysis useful for mass spectrometry experiments
involving protein turnover.

## Installation

NOTE: requires ruby >= 2.0

Until the Mercury7 algorithm is implemented you will need the fftw3 gem
installed.  It depends on the fftw3 library.  On Ubuntu/Debian, it's as easy
as this:

    sudo apt-get install libfftw3-dev

Then

    sudo gem install diadem

## Examples

Run diadem-cubic.rb from the commandline with no args to get help:

    diadem-cubic.rb

## LICENSE

GNU Public License version 3 (see LICENSE.txt).  Please contact the authors for 
consideration of releasing the software under different terms.

## Acronym 

Diadem stands for Dynamic Isotope Analysis DEMystified or maybe Dynamic Isotope
Analysis DEMarcated.
