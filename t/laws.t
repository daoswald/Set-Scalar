#
# $Id: laws.t,v 1.3 1996/05/17 06:13:29 jah Exp $
#
use Set::Scalar;

print "1..2375\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a $b $i $n $u get created

$| = 1;

print STDERR "(WARNING: this will take a while)...";

$t = 1;

# these are expected to fail because of the "universal trouble"
@expected{qw(141 217 522 674 712 731 807 1091 1130 1167 1358 1566 1642)} = 1;

sub ok {
    my ($l, $p, $q) = @_;

    print "# $l: $x $y $z: $p $q\n";
    print 'not ' if (not ($p == $q) and not exists $expected{$t});
    print "ok $t\n";
    $t++;
}

for $x ($a, $b, $i, $n, $u) {
    for $y ($a, $b, $i, $n, $u) {
	for $z ($a, $b, $i, $n, $u) {

#  1. --X == X				Law of Double Complement
	    &ok('1', -(-$x), $x);

#  2a. -(X + Y) == -X * -Y		DeMorgan's Laws
	    &ok('2a', -($x + $y),-$x * -$y);

#  2b. -(X * Y) == -X + -Y		DeMorgan's Laws
	    &ok('2b', -($x * $y), -$x + -$y);

#  3a. X + Y == Y + X			Commutative Laws
	    &ok('3a', $x + $y, $y + $x);

#  3b. X * Y == Y * X			Commutative Laws
	    &ok('3b', $x * $y, $y * $x);

#  4a. X + (Y + Z) == (X + Y) + Z	Associative Laws
	    &ok('4a', $x * $y, $y * $x);

#  4b. X * (Y * Z) == (X * Y) * Z	Associative Laws
	    &ok('4b', $x * $y, $y * $x);

#  5a. X + (Y * Z) == (X + Y) * (X + Z)	Distributive Laws
	    &ok('5a', $x + ($y * $z), ($x + $y) * ($x + $z));
	    print "# y * z = ", $y * $z, "\n";
	    print "# x + y = ", $x + $y, "\n";
	    print "# x + z = ", $x + $z, "\n";

#  5b. X * (Y + Z) == (X * Y) + (X * Z)	Distributive Laws
	    &ok('5b', $x * ($y + $z), ($x * $y) + ($x * $z));
	    print "# y + z = ", $y + $z, "\n";
	    print "# x * y = ", $x * $y, "\n";
	    print "# x * z = ", $x * $z, "\n";

#  6a. X + X == X			Idempotent Laws
	    &ok('6a', $x + $x, $x);

#  6b. X * X == X			Idempotent Laws
	    &ok('6b', $x * $x, $x);

#  7a. X + N == X			Identity Laws
	    &ok('7a', $x + $n, $x);

#  7b. X * U == X			Identity Laws
	    &ok('7b', $x * $u, $x);

#  8a. X + -X == U			Inverse Laws
	    &ok('8a', $x + -$x, $u);

#  8b. X * -X == N			Inverse Laws
	    &ok('8b', $x * -$x, $n);

#  9a. X + U == U			Domination Laws
	    &ok('9a', $x + $u, $u);

#  9b. X * N == N			Domination Laws
	    &ok('9b', $x * $n, $n);

# 10a. X + (X * Y) == X			Absorption Laws
	    &ok('10a', $x + ($x * $y), $x);

# 10b. X * (X + Y) == X			Absorption Laws
	    &ok('10b', $x * ($x + $y), $x);
	}
    }
}



# eof
