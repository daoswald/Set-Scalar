require 5;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   =>	'Set::Scalar',
    'VERSION_FROM' =>	'Scalar.pm',
    'dist'         => { 'COMPRESS' => 'gzip' },
);
