#
# $Id: modify.t,v 1.1 1996/03/17 08:49:15 jah Exp jah $
#

use Set::Scalar;

print "1..13\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a gets created

$a->insert('x');

print 'not ' unless ("$a" eq '(a b c d x)');
print "ok 1\n";

print 'not ' unless ($a->in('a'));
print "ok 2\n";

print 'not ' unless ($a->in('x'));
print "ok 3\n";

$a->delete('x');

print 'not ' unless ("$a" eq '(a b c d)');
print "ok 4\n";

print 'not ' unless ($a->in('a'));
print "ok 5\n";

print 'not ' if ($a->in('x'));
print "ok 6\n";

$x = $a;

$a->insert('x');

print 'not ' unless ("$e" eq '((a b c d) h i)');
print "ok 7\n";
undef $e; # fool -w

print 'not ' unless ("$x" eq '(a b c d x)');
print "ok 8\n";

print 'not ' unless ($x->in('a'));
print "ok 9\n";

print 'not ' unless ($x->in('x'));
print "ok 10\n";

$a->delete('x');

print 'not ' unless ("$x" eq '(a b c d)');
print "ok 11\n";

print 'not ' unless ($x->in('a'));
print "ok 12\n";

print 'not ' if ($x->in('x'));
print "ok 13\n";

# eof
