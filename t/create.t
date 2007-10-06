#
# $Id: create.t,v 1.1 1996/03/17 08:48:49 jah Exp jah $
#

use Set::Scalar;

$a = Set::Scalar->new('a', 'b', 'c', 'd');  
$b = Set::Scalar->new('c', 'd', 'e', 'f');  
$c = Set::Scalar->new(qw(d e));             
$d = Set::Scalar->new({'f', 12, 'g', 34});  
$e = Set::Scalar->new($a, 'h', 'i');        
$n = Set::Scalar->null;                     
$u = Set::Scalar->universal;                

$i = $a->inverse;
$i = -$a;

unless ($no_create_test) {
	print "1..8\n";

	print 'not ' unless ("$a" eq '(a b c d)');
	print "ok 1\n";

	print 'not ' unless ("$b" eq '(c d e f)');
	print "ok 2\n";

	print 'not ' unless ("$c" eq '(d e)');
	print "ok 3\n";

	print 'not ' unless ("$d" eq '(f=12 g=34)');
	print "ok 4\n";

	print 'not ' unless ("$e" eq '((a b c d) h i)');
	print "ok 5\n";

	print 'not ' unless ("$n" eq '()');
	print "ok 6\n";

	print 'not ' unless ("$u" eq '-()');
	print "ok 7\n";

	print 'not ' unless ("$i" eq '-(a b c d)');
	print "ok 8\n";

	$no_create_test = 0; # fool -w
}

# eof
