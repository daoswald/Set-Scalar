#
# $Id: Scalar.pm,v 1.4 1998/10/05 19:28:22 jhi Exp jhi $
#
# Module:	Set::Scalar.pm
#
# Author:	Jarkko Hietaniemi <Jarkko.Hietaniemi@iki.fi>
#
# Purpose:	provide the basic set operations for Perl
#		scalar/reference data.
#
# Requires:	Perl 5.002
#
# EXPORT:	-
#
# EXPORT_OK:	see below.
#
# Public:	&new &inverse(unary -) &null &universal
# (overloads)	&members &values &valued_members &grep &map
#		&union(+) &intersection(*) &difference(binary -)
#		&symmetric_difference(%)
#		&as_string("") &display_attr
#		&insert(+=) &delete(-=)
#		&in &power_set
#		&is_null &is_universal &is_valued
#		&compare(<=>) &equal(==) &disjoint(!=)
#		&proper_subset(<) &proper_superset(>)
#		&subset(<=) &superset(>=)
#		&intersect &DESTROY
#
# Private:	&_merge &_underload &_members
#		&_power
#		%_DISPLAY_ATTR &_DISPLAY_SORT
#		$_NULL $_UNIVERSAL
#

package Set::Scalar;

$VERSION = 0.00401;

require 5.002;

use vars qw($SELF $_NULL $_UNIVERSAL %_DISPLAY_ATTR @EXPORT_OK);

$SELF = 'Set::Scalar';

$_NULL      = undef;
$_UNIVERSAL = undef;

sub _DISPLAY_SORT { $a cmp $b }

%_DISPLAY_ATTR =
  (
   'format',		'%s(%m)',
   'inverse',		'-',
   'exists',		'',
   'member_separator',	' ',
   'value_style',	'parallel',
   'value_indicator',	'=',
   'value_separator',	' ',
   'sort',		'_DISPLAY_SORT',
  );

use overload
    '""'  =>		'as_string',
    'neg' =>		'inverse',
    '+'   =>		'union',
    '*'   =>		'intersection',
    '%'   =>		'symmetric_difference',
    '-'   =>		'difference',
    '='  =>		'copy',
    '+='  =>		'insert',
    '-='  =>		'delete',
    '<=>' =>		'compare',
    '=='  =>		'equal',
    '!='  =>		'disjoint',
    '<'   =>		'proper_subset',
    '>'   =>		'proper_superset',
    '<='  =>		'subset',
    '>='  =>		'superset';

@EXPORT_OK =
  qw(
     as_string
     union
     intersection
     symmetric_difference
     difference
     copy
     insert
     delete
     in
     compare
     equal
     disjoint
     proper_subset
     proper_superset
     subset
     superset
    );

# use strict qw(vars subs);

=head1 NAME

Set::Scalar - the basic set operations for Perl scalar/reference data

=head1 SYNOPSIS

    use Set::Scalar;

or

    use Set::Scalar qw(union intersection);

to import, for example, C<union> and C<intersection> to the current
namespace. By default nothing is imported, the exportable routines
are B<as_string union intersection symmetric_difference difference in
compare equal disjoint proper_subset proper_superset subset superset>,
please see below for further documentation.

=head1 DESCRIPTION

Sets are created with C<new>. Lists as arguments for C<new> give
normal sets, hash references (please see C<perlref>) give
B<valued sets>. The special sets, C<null set> or the B<none>, B<empty>,
set, and the C<universal set> or the B<all> are created with C<null>
and C<universal>.

    $a = Set::Scalar->new('a', 'b', 'c', 'd');	# set members
    $b = Set::Scalar->new('c', 'd', 'e', 'f');	# set members
    $c = Set::Scalar->new(qw(d e));		# set members
    $d = Set::Scalar->new({'f', 12, 'g', 34});	# 'valued' set
    $e = Set::Scalar->new($a, 'h', 'i');	# sets are recursive
    $n = Set::Scalar->null;			# the empty set
    $u = Set::Scalar->universal;		# the 'all' set

B<Valued sets> are "added value" sets: normal sets have only their
members but valued sets have one scalar/ref value per each of their
member. See the discussion about C<values> and C<valued_members>
for how to retrieve the values.

Set inversion or the B<not> set is done with C<inverse> or
the overloaded prefix operator C<->.

    $i = $a->inverse;				# the 'not' set
    $i = -$a;				# or with the overloaded -

Displaying sets is done with C<as_string> or more commonly with
the overloaded stringification "operator" C<">.

    print "a = ", $a->as_string, "\n";
    print "b = $b\n";			# or with the overloaded "
    print "c = $c\n";
    print "d = $d\n";
    print "e = ", $e, "\n";
    print "i = $i\n";
    print "n = $n\n";
    print "u = $u\n";

B<NOTE>: please do not try to display circular sets. Yes, circular
sets can be built. Yes, trying to display them will cause infinite
recursion.

The usual set operations are done with C<union>, C<intersection>,
C<symmetric_difference>, and C<difference>, or with their overloaded
infix operator counterparts, C<+>, C<*>, C<%>, and C<->.

    print "union(a,b) = ", Set::Scalar->union($a, $b), "\n";
    print "a + b = ", $a + $b, "\n";	# or with the overloaded +

    print "intersection(a,b) = ", Set::Scalar->intersection($a, $b), "\n";
    print "a * b = ", $a * $b, "\n";	# or with the overloaded *

    print "symmdiff(a,b) = ", Set::Scalar->symmetric_difference($a, $b), "\n";
    print "a % b = ", $a % $b, "\n";	# or with the overloaded %

    print "difference(a,b) = ", Set::Scalar->difference($a, $b), "\n";
    print "a - b = ", $a - $b, "\n";	# or with the overloaded -

B<NOTE>: the distributive laws (please see LAWS or t/laws.t in the
Set::Scalar distribution) cannot always be satisfied. This is because
in set algebra B<the whole universe> (all the possible members of all
the possible sets) is supposed to be defined beforehand I<BUT> the set
operations see only two sets at a time. This can cause the
distributive laws

	X + (Y * Z) == (X + Y) * (X + Z)
	X * (Y + Z) == (X * Y) + (X * Z)

to fail because the C<+> and C<*> do not necessarily "see" all
the members of the C<X>, C<Y>, C<Z> in time. Beware this effect
especially when having simultaneously any two of the X, Y, Z, being
identical in members except the other being inverted, or one the
X, Y, Z, being the null set.

Modifying sets C<in-place> is done with C<insert> and C<delete>
or their overload counterparts C<+=> and C<-=>.
Testing for membership is done with C<in>.

    print "a  = $a\n";
    $a->insert('x');
    print "a' = $a\n";
    print 'x is', $a->in('x') ? '' : ' not', " in a\n";
    $a->delete('x');
    print "a  = $a\n";
    print 'x is', $a->in('x') ? '' : ' not', " in a\n";

B<NOTE>: set copying by C<=> is shallow. Sets are objects and the C<=>
copies only the topmost level. That is, the copy is a B<reference> to
the original set.

    $x = $a;
    print "a  = $a, x = $x, e = $e\n";
    $a->insert('x');
    print "a' = $a, x = $x, e = $e\n";	# also the 'copy' of a changes
    $a->delete('x');
    print "a' = $a, x = $x, e = $e\n";

For deep ("real") copying use C<copy> (or ->new($set)).

    $y = $e->copy;
    print "a  = $a, y = $y, e = $e\n";
    $a->insert('y');
    # the (real, deep) copy does not change
    print "a' = $a, y = $y, e = $e\n";
    $a->delete('y');
    print "a' = $a, y = $y, e = $e\n";

Testing sets is done with C<is_null>, C<is_universal>, C<is_inverted>,
and C<is_valued>.

    print 'a is', $a->is_null      ? '' : ' not', " null\n";
    print 'a is', $a->is_universal ? '' : ' not', " universal\n";
    print 'a is', $a->is_inverted  ? '' : ' not', " inverted\n";
    print 'a is', $a->is_valued    ? '' : ' not', " valued\n";
    print 'd is', $d->is_null      ? '' : ' not', " null\n";
    print 'd is', $d->is_universal ? '' : ' not', " universal\n";
    print 'd is', $a->is_inverted  ? '' : ' not', " inverted\n";
    print 'd is', $d->is_valued    ? '' : ' not', " valued\n";
    print 'i is', $i->is_null      ? '' : ' not', " null\n";
    print 'i is', $i->is_universal ? '' : ' not', " universal\n";
    print 'i is', $i->is_inverted  ? '' : ' not', " inverted\n";
    print 'i is', $i->is_valued    ? '' : ' not', " valued\n";
    print 'n is', $n->is_null      ? '' : ' not', " null\n";
    print 'n is', $n->is_universal ? '' : ' not', " universal\n";
    print 'n is', $n->is_inverted  ? '' : ' not', " inverted\n";
    print 'n is', $n->is_valued    ? '' : ' not', " valued\n";
    print 'u is', $u->is_null      ? '' : ' not', " null\n";
    print 'u is', $u->is_universal ? '' : ' not', " universal\n";
    print 'u is', $u->is_inverted  ? '' : ' not', " inverted\n";
    print 'u is', $u->is_valued    ? '' : ' not', " valued\n";

Comparing sets is done with

	compare
	equal
	disjoint
        intersect
	proper_subset
	proper_superset
	subset
	superset

or more commonly with their overloaded infix operator counterparts

	<=>
	==
	!=
    	<>
	<
	>
	<=
	=>

B<NOTE>: The C<compare> is a multivalued relational operator, not a
binary (two-valued) one. It returns a B<string> that is one of

	==
	!=
	<>
	<
	>
	<=
	=>

The C<equal>, C<disjoint>, C<intersect>, C<proper_subset>,
C<proper_superset>, C<subset>, and C<superset>, B<are> binary (true or
false) relational operators.

The difference between C<disjoint> and C<intersect> is that the former
means completely disjoint, no common members at all, and the latter
means partly disjoint, some common members, some not.

    print "a <=> a = '", $a <=> $a, "'\n";
    print "a == c\n" if ($a == $c);
    print "b <=> c = '", $b <=> $c, "'\n";
    print "c <=> b = '", $c <=> $b, "'\n";
    print "b >= c\n" if ($b >= $c);
    print "c <  b\n" if ($c <  $b);
    print "a <=> c = '", $a <=> $c, "'\n";
    print "a <=> d = '", $a <=> $d, "'\n";

B<NOTE>: please do not try to "sort" sets based on the C<subset> and
C<superset> relational operators. This will not work in general case
because sets can have circular relationships. Circular sets will cause
infinite recursion.

The set members can be accessed with C<members>. For the valued sets
either the values can be accessed with C<values> as a list or both the
members and the values with C<valued_members> as a hash. B<None of
these returns the items in any particular order>, the sets of
Set::Scalar are unordered.

    for $i ($a->members) {		print "a: $i\n"; }

    for $i (Set::Scalar->values($d)) {	print "d: $i\n"; }

    %d = $d->valued_members;
    while (($k, $v) = each %d) {	print "d: $k $v\n"; }

Sets can be C<grep>ed and C<map>ped.

    %g = $a->grep(sub { $_[0] eq 'b' });
    $g = Set::Scalar->new(keys %g);
    print "g = $g\n";

    %m = $d->map(sub { my ($k, $v, $d) = @_;
                       $k =~ tr/a-z/A-Z/;
                       $v *= $v;
                       $d = $k ne 'G';
                       ($k, $v, $d); });
    $m = Set::Scalar->new({ %m });
    print "m = $m\n";

The power set (the set of all the possible subsets of a set) is
generated with C<power_set>.

    $p = $a->power_set;
    print "p = $p\n";

Displaying sets can be fine-tuned either per set or by changing
the global default display attributes using the C<display_attr>
with two arguments. The display attributes can be examined
using the C<display_attr> with one argument.

The display attributes are:

C<format>, a string which should contain magic sequences C<%s> which
marks the place of the B<signedness> (normal or inverted) of set, and
C<%m>, which marks the place of the members of the set. The default
is C<%s(%m)>

C<inverse>, a string that tells how to mark an inverted set
(the C<%s> in C<format>). The default is C<->.

C<exists>, a string that tells how to mark an "existing" set.  An
"existing" set? It is a set that is not inverted, that is, a set that
is "not not", (the C<%s> in C<format>). The default is ''.

C<member_separator>, a string that tells how to separate the
members of the set, (the C<%m> in C<format>). The default is ' '.

C<value_style>, a string that tells how to display valued sets.
Only two styles are defined: C<parallel> (the default) or C<serial>.
The former means that the order is

    m1 v1 m2 v2 ...

and the latter means that the order is

    m1 m2 ... v1 v2 ...

C<value_indicator>, a string that tells how to separate the members
from the values in the case of valued sets. In the C<parallel> style
there are as many C<value_indicator>s shown as there are members
(or values), in the C<serial> style only one C<value_indicator>
is shown.

C<value_separator>, a string that tells how to separate the members
and the values in case of C<serial> display of valued sets, (the C<%m>
in C<format>). The default is ' '.

C<sort>, a name of a subroutine that tells how to order the
members of the set. The default is '_DISPLAY_SORT' which sorts
the members alphabetically. This is why the displayed form is
something like this

    (a b c d)

and not anything random (to be exact, in hash order). Sets do not have
any particular order per se (please see the C<members> discussion).

    print "format(a) = ", $a->display_attr('format'), "\n";
    print "memsep(a) = ", $a->display_attr('member_separator'), "\n";
    print "format(b) = ", $b->display_attr('format'), "\n";
    print "memsep(b) = ", $b->display_attr('member_separator'), "\n";

    # changing the per-set display attributes

    $a->display_attr('format', '%s{%m}');
    $a->display_attr('member_separator', ',');
    print "a = $a, b = $b\n";
    print "format(a) = ", $a->display_attr('format'), "\n";
    print "memsep(a) = ", $a->display_attr('member_separator'), "\n";
    print "format(b) = ", $b->display_attr('format'), "\n";
    print "memsep(b) = ", $b->display_attr('member_separator'), "\n";

    # changing the default display attributes

    print "memsep = '", Set::Scalar->display_attr('member_separator'), "'\n";
    Set::Scalar->display_attr('member_separator', ':');
    print "memsep = '", Set::Scalar->display_attr('member_separator'), "'\n";
    print "a = $a, b = $b\n";
    Set::Scalar->display_attr('member_separator', ' ');

=head1 AUTHOR

Jarkko Hietaniemi, Jarkko.Hietaniemi@iki.fi

=cut

sub new {
  my $type = (ref $_[0] or @_ == 0) ? $SELF : shift;
  my ($self) = {};
  my ($m, $r, %m);

  my (%new) = ();
  my ($i, $v) = (0, 0);
  
  while (defined ($m = shift(@_))) {
    if ($r = ref $m) {
      if ($r eq 'HASH') {
	%m = %{$m};
	$v = 1;
	@new{keys %m} = values %m;
      } elsif ($r eq $SELF) {
	$new{$m} = undef;
      } else {
	die "${SELF}::new: unknown ref type '$r' for argument '$m'";
      }
    } else {
      $new{$m} = undef;
    }
  }

  $self->{'_set'}          = { %new };
  $self->{'_inverted'}     = $i;
  $self->{'_valued'}       = $v;
  $self->{'_display_attr'} = { };

  bless $self, $type;
}

sub _underload {
  shift if (@_ and not ref $_[0] and $_[0] eq $SELF);
  if (@_ == 3) {
    if (not defined $_[1] and $_[2] eq '') {
      splice(@_, 1, 2);
    }
  }

  @_;
}

sub inverse {
  my $i;
  my @i;

  @_ = _underload(@_);

  if (@_) {
    @i = map { $i = new(%$_->{'_set'});
	       $i->{'_inverted'} = ! $_->{'_inverted'};
               $i->{'_valued'} = 0;
	       $i } @_;
  } else {
    $i = new();
    $i->{'_inverted'} = ! $_->{'_inverted'};
    $i->{'_valued'} = 0;
    @i = ($i);
  }

  wantarray ? @i : $i[0];
}

sub as_string {
  @_ = _underload(@_);
  my @s = map {
    my $set  = $_;
    my $sort = $set->{'_display_attr'}->{'sort'} || $_DISPLAY_ATTR{'sort'};
    my @mems = sort $sort keys %{$set->{'_set'}};
    my $fmt  = $set->{'_display_attr'}->{'format'} ||
	       $_DISPLAY_ATTR{'format'};
    my $inv  = $set->{'_inverted'} ? 
               ( $set->{'_display_attr'}->{'inverse'} || 
		 $_DISPLAY_ATTR{'inverse'} ) :
		 ( $set->{'_display_attr'}->{'exists'} ||
		   $_DISPLAY_ATTR{'exists'} || '' );

    my $str  = $fmt;
    
    $str =~ s/%s/$inv/g;

    if (@mems) {
      my $mdsp = defined
                   $set->{'_display_attr'}->{'member_display'} ?
                   $set->{'_display_attr'}->{'member_display'} :
 	           $_DISPLAY_ATTR{'member_display'};
      my $msep = defined
                   $set->{'_display_attr'}->{'member_separator'} ?
                   $set->{'_display_attr'}->{'member_separator'} :
  	           $_DISPLAY_ATTR{'member_separator'};
      my @mdsp = (defined $mdsp) ? map { &$mdsp($_, $set) } @mems : @mems;
      my $mems = '';

      if ($set->{'_valued'}) {
	my $vdsp = defined
                     $set->{'_display_attr'}->{'value_display'} ?
  	             $set->{'_display_attr'}->{'value_display'} :
                     $_DISPLAY_ATTR{'value_display'};
	my $vstl = defined
                     $set->{'_display_attr'}->{'value_style'} ?
                     $set->{'_display_attr'}->{'value_style'} :
                     $_DISPLAY_ATTR{'value_style'};
	my $vind = defined
                     $set->{'_display_attr'}->{'value_indicator'} ?
                     $set->{'_display_attr'}->{'value_indicator'} :
	             $_DISPLAY_ATTR{'value_indicator'};
	my @vdsp;

	if ($vstl eq 'parallel') {
	  my %set = %{$set->{'_set'}};
	  
	  if (defined $vdsp) { # @@@: ???
	    @vdsp = map { "$_$vind".&$vdsp($_, $set{$_}) } @mdsp;
	  } else {
	    @vdsp = map { "$_$vind$set{$_}" } @mdsp;
	  }
          $mems = join($msep, @vdsp);
	} elsif ($vstl eq 'serial') {
	  my $vsep = $set->{'_display_attr'}->{'value_separator'} ||
  	             $_DISPLAY_ATTR{'value_separator'};
	  my @vals = @{$set->{'_set'}}{@mems};

	  @vdsp = (defined $vdsp) ? map { &$vdsp($_, $set) } @vals : @vals;
	  $mems = join($msep, @mdsp) . $vind . join($vsep, @vdsp);
	}
      } else {
	$mems = join($msep, @mdsp);
      }

      $str =~ s/%m/$mems/g;
    } else {
      my $sstr;

      undef($sstr);

      if ($set->{'_inverted'}) {
	my $univ = $set->{'_display_attr'}->{'universal'} ||
	           $_DISPLAY_ATTR{'universal'};

	$sstr = $univ if (defined $univ);
      } else {
	my $null = $set->{'_display_attr'}->{'null'} ||
	           $_DISPLAY_ATTR{'null'};

	$sstr = $null if (defined $null);
      }
      
      if (defined $sstr) {
	$str = $sstr;
      } else {
	$str =~ s/%m//g;
      }
    }

    $str;
  } @_;

  wantarray ? @s : $s[0];
}

sub display_attr {
  shift(@_) if (not ref $_[0] and $_[0] eq $SELF);
  my $r = ref $_[0];
  
  if (@_ == 1) {
    if ($r eq $SELF) {
      keys %{$_[0]->{'_display_attr'}};
    } else {
      $_DISPLAY_ATTR{$_[0]};
    }
  } elsif (@_ == 2) {
    if ($r eq $SELF) {
      defined ${_[0]}->{'_display_attr'}->{$_[1]} ?
              ${_[0]}->{'_display_attr'}->{$_[1]} :
              $_DISPLAY_ATTR{$_[1]};
    } else {
      $_DISPLAY_ATTR{$_[0]} = $_[1];
    }
  } elsif (@_ == 3) {
    $_[0]->{'_display_attr'}->{$_[1]} = $_[2];
  } else {
    die "${SELF}::display_attr: unknown number of arguments: ",
        scalar @_, "\n";
    
  }
}

sub null {
  $_NULL = new() unless (defined $_NULL);

  $_NULL;
}

sub universal {
  $_UNIVERSAL = inverse() unless (defined $_UNIVERSAL);

  $_UNIVERSAL;
}

sub is_null {
  my @t =
    map {
      keys %{$_->{'_set'}} == 0 and not $_->{'_inverted'};
    } @_;

  wantarray ? @t : $t[0];
}

sub is_universal {
  my @t =
    map {
      keys %{$_->{'_set'}} == 0 and     $_->{'_inverted'};
    } @_;

  wantarray ? @t : $t[0];
}

sub is_inverted {
  my @t =
    map {
      $_->{'_inverted'} and keys %{$_->{'_set'}}
    } @_;

  wantarray ? @t : $t[0];
}

sub is_valued {
  my @t =
    map {
      $_->{'_valued'};
    } @_;

  wantarray ? @t : $t[0];
}

sub _members {
  my ($s, %u) = @_;
  
  if ($s->{'_inverted'}) {
    my %v = %u;
    my $c;

    for $c (keys %{$s->{'_set'}}) { delete $v{$c} }
    
    keys %v;
  } else {
    keys %{$s->{'_set'}};
  }
}

sub members {
  @_ = _underload(@_);
  my (%m) = ();

  map {
    @m{keys %{$_->{'_set'}}} = undef;
  } @_;

  keys %m;
}

sub values {
  @_ = _underload(@_);
  my (%m) = ();

  map {
    @m{values %{$_->{'_set'}}} = undef;
  } @_;

  keys %m;
}

sub valued_members {
  @_ = _underload(@_);
  my (%m) = ();

  map {
    @m{keys %{$_->{'_set'}}} = CORE::values %{$_->{'_set'}};
  } @_;

  %m;
}

sub grep {
  @_ = _underload(@_);
  my $g;
  my (%m) = ();
  my $k;

  $g = (@_ == 2 and ref $_[1] eq 'CODE') ? splice(@_, 1, 1) : shift(@_);

  map {
    for $k (keys %{$_->{'_set'}}) {
      $m{$k} = $_->{'_set'}->{$k} if (&{$g}($k, $_->{'_set'}->{$k}));
    }
  } @_;

  %m;
}

sub map {
  @_ = _underload(@_);
  my $m;
  my (%m) = ();
  my ($k, $v, $d);

  $m = (@_ == 2 and ref $_[1] eq 'CODE') ? splice(@_, 1, 1) : shift(@_);

  map {
    for $k (keys %{$_->{'_set'}}) {
      ($k, $v, $d) = &{$m}($k, $_->{'_set'}->{$k});
      $m{$k} = $v if ($d);
    }
  } @_;

  %m;
}

sub _power {
  my ($p, $i, $n, $m, $a) = @_;
  my @a = @{$a};

  if ($i--) {
    _power($p, $i, $n, $m, [ @a ]);
    _power($p, $i, $n, $m, [ @{$m}[$i], @a ]);
  } else {
    push(@{$p}, new($SELF, @a));
  }
}

sub power_set {
  @_ = _underload(@_);
  my $m = _merge('union', @_);
  my @m = keys %{$m->{'_set'}};
  my $s = new(@m);
  my $n = @m;
  my $p = [];

  _power($p, $n, $n, \@m, []);

  new($SELF, @{$p});
}

sub compare {
  @_ = _underload(@_);

  my ($a, $b, $na, $nb, %nab, @ka, @kb, $nab, $nple, $tuple, $c);
  my (%u) = ();

  for $a (@_) {
    @u{keys %{$a->{'_set'}}} = undef;
  }

  $a = shift;

  @ka = _members($a, %u);
  $na = @ka;

  $nple = undef;

  do {

    tuple: {
      $b = shift;

      @kb = _members($b, %u);
      $nb = @kb;
      
      %nab = ();
      @nab{@ka, @kb} = undef;
      $nab = scalar keys %nab;

      if ($nab and $nab == $na + $nb) {
	$tuple = '!=';
	last;
      } elsif ($nab == $na) {
	$tuple = ($na == $nb) ? '==' : '>';
	last;
      } elsif ($nab == $nb) {
	$tuple = '<';
	last;
      }
      $tuple = '<>';
    }

    if (defined $nple) {
      if ($tuple ne $nple) {
        if (($nple eq '>' and $tuple eq '==')
            or
            ($nple eq '==' and $tuple eq '<')
            or
            ($nple eq '>='
             and
             ($tuple eq '>' or $tuple eq '=='))
            ) {
          $nple = '>=';
        } elsif (($nple eq '<' and $tuple eq '==')
                 or
                 ($nple eq '==' and $tuple eq '<')
                 or
                 ($nple eq '<='
                  and
                  ($tuple eq '<' or $tuple eq '=='))
                 ) {
          $nple = '<=';
        } else {
          return undef;
        }
      }
    } else {
      $nple = $tuple;
    }
    shift(@_);
    if (@_) {
      @ka = @kb;
      $na = $nb;
    }
  } while (@_);

  $nple;
}

sub equal           { compare(@_) eq '==' }
sub disjoint        { compare(@_) eq '!=' }
sub proper_subset   { compare(@_) eq '<' }
sub proper_superset { compare(@_) eq '>' }
sub subset          { my $c = compare(@_); $c eq '<' or $c eq '<=' }
sub superset        { my $c = compare(@_); $c eq '>' or $c eq '>=' }
sub intersect       { compare(@_) eq '<>' }

sub _merge {
  my ($op) = shift;

  @_ = _underload(@_);

  my (%m, $un, $is, $sd);
  my ($a, $k, @ka, $is_universal);
  my ($n, $nu) = (0, 0);
  my (%u) = ();

  pop(@_) if (@_ == 3 and not ref $_[2] and $_[2] eq '');

  for $a (@_) {
    @u{keys %{$a->{'_set'}}} = undef;
  }

  if (($un = $op eq 'union') or
      ($is = $op eq 'intersection') or
      ($sd = $op eq 'symmetric_difference')) {
    if ($un) {
      for $a (@_) {
	$is_universal = 1 if ($a->{'_inverted'} and keys %{$a->{'_set'}} == 0);
	@m{_members($a, %u)} = undef;
      }
    } elsif ($is or $sd) {
      for $a (@_) {
	$n++;
	$nu++ if ($a->{'_inverted'} and keys %{$a->{'_set'}} == 0);
	for $k (_members($a, %u)) {
	  $m{$k}++;
	}
      }
    }
    if ($is) {
      for $a (keys %m) {
	delete $m{$a} if ($m{$a} < $n);
      }
      $is_universal = 1 if ($nu == $n);
    } elsif ($sd) {
      for $a (keys %m) {
	delete $m{$a} if ($m{$a} > 1);
      }
    }
  }

  my $m = $is_universal ? universal() : new($SELF, keys %m);
  
  $m;
}

sub union                { _merge('union',                @_) }
sub intersection         { _merge('intersection',         @_) }
sub symmetric_difference { _merge('symmetric_difference', @_) }

sub difference {
  @_ = _underload(@_);
  my $f = shift;
  my $r = _merge('union', @_);

  _merge('intersection', $f, inverse($r));
}

sub insert {
  @_ = _underload(@_);
  my $s = shift;
  my $m = new($SELF, @_);
  my $k;

  for $k (keys %{$m->{'_set'}}) {
    $s->{'_set'}->{$k} = undef;
  }
 
  $s;
}

sub delete {
  @_ = _underload(@_);
  my $s = shift;
  my $m = new($SELF, @_);
  my $k;

  for $k (keys %{$m->{'_set'}}) {
    delete $s->{'_set'}->{$k};
  }

  $s;
}

sub in {
  @_ = _underload(@_);
  my $s = shift;
  my $m = new($SELF, @_);
  my $k;
  my @i = ();
  
  map {
    push(@i, exists $s->{'_set'}->{$_});
  } keys %{$m->{'_set'}};
  
  wantarray ? @i : $i[0];
}

sub copy {
  @_ = _underload(@_);
  my ($c, $r, $m, $k);
  $m = shift;
  $r = ref $m;
  if ($r and $r eq $SELF) {
    $c = new($SELF);
    $c->{'_inverted'}     = $m->{'_inverted'};
    $c->{'_display_attr'} = $m->{'_display_attr'};	# @@@: deep copy here?
    if ($m->{'_valued'}) {
      $c->{'_valued'} = 1;
      for $k (keys %{$m->{'_set'}}) {
	$c->{'_set'}->{$k} = $m->{'_set'}->{$k};
      }
    } else {
      for $k (keys %{$m->{'_set'}}) {
	$c->{'_set'}->{$k} = undef;
      }
    }
  }
  
  $c;
}

sub DESTROY {
 # print "${SELF}::DESTROY(@_)\n";
}

1;

# eof
