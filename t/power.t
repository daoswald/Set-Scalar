#
# $Id: power.t,v 1.1 1996/03/17 08:49:33 jah Exp $
#

use Set::Scalar;

print "1..1\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a get created

$p = $a->power_set;
print 'not ' unless ("$p" eq "(() (a b c d) (a b c) (a b d) (a b) (a c d) (a c) (a d) (a) (b c d) (b c) (b d) (b) (c d) (c) (d))");
print "ok 1\n";

# eof
