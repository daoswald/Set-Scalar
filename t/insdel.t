#
# $Id: insdel.t,v 1.1 1996/05/17 06:35:23 jah Exp jah $
#

use Set::Scalar;

print "1..8\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a $b $c get created

$a->insert('e');
print 'not ' unless ("$a" eq "(a b c d e)");
print "ok 1\n";

$a->delete('e');
print 'not ' unless ("$a" eq "(a b c d)");
print "ok 2\n";

$b->insert($c);
print 'not ' unless ("$b" eq "((d e) c d e f)");
print "ok 3\n";

$b->delete($c);
print 'not ' unless ("$b" eq "(c d e f)");
print "ok 4\n";

# and then the same with overloads.

$a += 'e';
print 'not ' unless ("$a" eq "(a b c d e)");
print "ok 5\n";

$a -= 'e';
print 'not ' unless ("$a" eq "(a b c d)");
print "ok 6\n";

$b += $c;
print 'not ' unless ("$b" eq "((d e) c d e f)");
print "ok 7\n";

$b -= $c;
print 'not ' unless ("$b" eq "(c d e f)");
print "ok 8\n";

# eof
