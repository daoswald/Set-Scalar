#
# $Id: compare.t,v 1.1 1996/03/17 08:48:40 jah Exp $
#

use Set::Scalar;

print "1..8\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a $b $c $d get created

print 'not ' unless (($a <=> $a) eq '==');
print "ok 1\n";

print 'not ' if ($a == $c);
print "ok 2\n";

print 'not ' unless (($b <=> $c) eq '>');
print "ok 3\n";

print 'not ' unless (($c <=> $b) eq '<');
print "ok 4\n";

print 'not ' unless ($b >= $c);
print "ok 5\n";

print 'not ' unless ($c <  $b);
print "ok 6\n";

print 'not ' unless (($a <=> $b) eq '<>');
print "ok 7\n";

print 'not ' unless (($a <=> $d) eq '!=');
print "ok 8\n";
undef $d; # fool -w

# eof
