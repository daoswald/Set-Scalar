print "Welcome to Set::Scalar!\n" unless -f "Makefile";

require 5.004_04;

use ExtUtils::MakeMaker;

WriteMakefile(
	      'NAME'         => 'Set::Scalar',
	      'VERSION_FROM' => 'lib/Set/Scalar.pm',
	      'dist'         => { 'COMPRESS' => 'gzip' },
	      )
and
print "Now issue 'make' and then 'make test'.\n";
