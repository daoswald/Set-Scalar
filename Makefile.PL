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
	       'Test::More'	=> 0,
	      },
	      )
and
print <<__EOF__;
Now issue 'make' and then 'make test', and if all looks good, 'make install'.
__EOF__
eval 'use Test::More';
if ($@) {
print <<__EOF__;
(Test::More not found means that you cannot run the tests, you can
still go ahead and install without testing if you are feeling brave.)
__EOF__
}



