#
# $Id: members.t,v 1.1 1996/03/17 08:49:06 jah Exp jah $
#

use Set::Scalar;

print "1..5\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a $b $c $d get created

@m = $a->members;
print 'not ' unless ("@m" eq "a b c d");
print "ok 1\n";

@v = Set::Scalar->values($d);
print 'not ' unless ("@v" eq "12 34");
print "ok 2\n";

@vm = Set::Scalar->valued_members($d);
print 'not ' unless ("@vm" eq "f 12 g 34");
print "ok 3\n";

%g = $a->grep(sub { $_[0] eq 'b' });
$g = Set::Scalar->new(keys %g);
print 'not ' unless ("$g" eq "(b)");
print "ok 4\n";

%m = $d->map(sub { my ($k, $v, $d) = @_;
		   $k =~ tr/a-z/A-Z/;
		   $v *= $v;
		   $d = $k ne 'G';
		   ($k, $v, $d); });
$m = Set::Scalar->new({ %m });
print 'not ' unless ("$m" eq "(F=144)");
print "ok 5\n";

# eof
