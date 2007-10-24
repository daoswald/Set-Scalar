print "Welcome to Set::Scalar!\n" unless -f "Makefile";

require 5.004_04;

use ExtUtils::MakeMaker;

WriteMakefile(
	      'NAME'         => 'Set::Scalar',
	      'VERSION_FROM' => 'lib/Set/Scalar.pm',
	      'dist'         => { 'COMPRESS' => 'gzip' },
              PREREQ_PM       =>
	      {
	       # 'Scalar::Util'	=> 0, # Not a requirement anymore.
	       # 'Test::More'	=> 0,
	      },
	      )
and
print <<__EOF__;
Now issue 'make' and then 'make test', and if all looks good, 'make install'.
__EOF__
