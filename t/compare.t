use Set::Scalar;

$t = Set::Scalar->new(qw(a b c));
$u = Set::Scalar->new(qw(a b c));
$v = Set::Scalar->new(qw(d e f));
$w = Set::Scalar->new(qw(a b));
$x = Set::Scalar->new(qw(b c d));

print "1..14\n";

print "not " unless $t == $u;
print "ok 1\n";

print "not " unless $t != $v;
print "ok 2\n";

print "not " if $t == $v;
print "ok 3\n";

print "not " if $t == $w;
print "ok 4\n";

print "not " unless $t > $w;
print "ok 5\n";

print "not " unless $w < $t;
print "ok 6\n";

print "not " unless $t >= $u;
print "ok 7\n";

print "not " unless $t <= $u;
print "ok 8\n";

print "not " unless $t >= $w;
print "ok 9\n";

print "not " unless $w <= $t;
print "ok 10\n";

print "not " unless $t == "(a b c)";
print "ok 11\n";

print "not " unless "(a b c)" == $u;
print "ok 12\n";

print "not " unless $t->compare($x) eq 'proper intersect';
print "ok 13\n";

print "not " unless $t->compare($v) eq 'disjoint';
print "ok 14\n";

