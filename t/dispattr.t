#
# $Id: dispattr.t,v 1.1 1996/03/17 08:48:06 jah Exp jah $
#

use Set::Scalar;

print "1..11\n";

$no_create_test = 0; # fool -w
$no_create_test = 1;

require 't/create.t'; # $a $b get created

print 'not ' unless ($a->display_attr('format') eq '%s(%m)');
print "ok 1\n";

print 'not ' unless ($a->display_attr('member_separator') eq ' ');
print "ok 2\n";

$a->display_attr('format', '%s{%m}');
$a->display_attr('member_separator', ',');

print 'not ' unless ($a->display_attr('format') eq '%s{%m}');
print "ok 3\n";

print 'not ' unless ($a->display_attr('member_separator') eq ',');
print "ok 4\n";

print 'not ' unless ($b->display_attr('format') eq '%s(%m)');
print "ok 5\n";

print 'not ' unless ($b->display_attr('member_separator') eq ' ');
print "ok 6\n";

print 'not ' unless ("$a" eq "{a,b,c,d}");
print "ok 7\n";

print 'not ' unless ("$b" eq "(c d e f)");
print "ok 8\n";

Set::Scalar->display_attr('member_separator', ':');

print 'not ' unless ("$a" eq "{a,b,c,d}");
print "ok 9\n";

print 'not ' unless ("$b" eq "(c:d:e:f)");
print "ok 10\n";

Set::Scalar->display_attr('member_separator', ' ');

print 'not ' unless ("$b" eq "(c d e f)");
print "ok 11\n";

# eof
