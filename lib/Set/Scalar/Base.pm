package Set::Scalar::Base;

use strict;
local $^W = 1;

require Exporter;

use vars qw(@ISA @EXPORT_OK);

@ISA = qw(Exporter);

use UNIVERSAL 'isa';

@EXPORT_OK = qw(_make_elements
		as_string
		_compare is_equal
		_binary_underload
		_unary_underload
		_strval);

use overload
    '+'		=> \&_union_overload,
    '*'		=> \&_intersection_overload,
    '-'		=> \&_difference_overload,
    'neg'	=> \&_complement_overload,
    '%'		=> \&_symmetric_difference_overload,
    '/'		=> \&_unique_overload,
    'eq'	=> \&is_equal,
    '=='	=> \&is_equal,
    '!='	=> \&is_disjoint,
    '<=>'	=> \&compare,
    '<'		=> \&is_proper_subset,
    '>'		=> \&is_proper_superset,
    '<='	=> \&is_subset,
    '>='	=> \&is_superset,
    'bool'	=> \&size;

use constant OVERLOAD_BINARY_2ND_ARG  => 1;
use constant OVERLOAD_BINARY_REVERSED => 2;

sub _binary_underload { # Handle overloaded binary operators.
    my (@args) = @{ $_[0] };

    if (@args == 3) {
	$args[1] = (ref $args[0])->new( $args[1] ) unless ref $args[1];
	@args[0, 1] = @args[1, 0] if $args[OVERLOAD_BINARY_REVERSED];
	pop @args;
    }

    return @args;
}

sub _unary_underload { # Handle overloaded unary operators.
    if (@{ $_[0] } == 3) {
	pop @{ $_[0] };
	pop @{ $_[0] };
    }
}

sub _new_hook {
    # Just an empty stub.
}

sub new {
    my $class = shift;

    my $self = { };

    bless $self, $class;

    $self->_new_hook( \@_ );

    return $self;
}

sub _strval {
    my $class = ref $_[0];
    return $_[0] unless $class;
    bless $_[0], 'Set::Scalar::Base::NonOverloaded';
    my $strval = "$class($_[0])";
    bless $_[0], $class;
    return $strval;
}

sub _make_elements {
    return map { (defined $_ ? _strval($_) : "") => $_ } @_;
}

sub _invalidate_cached {
    my $self = shift;

    delete @{ $self }{ "as_string" };
}

sub _insert_hook {
    # Just an empty stub.
}

sub _insert {
    my $self     = shift;
    my $elements = shift;

    $self->_insert_hook( $elements );
}

sub _insert_elements {
    my $self     = shift;
    my $elements = shift;

    @{ $self->{'elements'} }{ keys %$elements } = values %$elements;

    $self->_invalidate_cached;
}

sub universe {
    my $self = shift;

    return $self->{'universe'};
}

sub size {
    my $self = shift;

    return scalar keys %{ $self->{'elements'} };
}

sub elements {
    my $self = shift;

    return @_ ?
	@{ $self->{'elements'} }{ map { _strval($_) } @_ } :
	values %{ $self->{'elements'} };
}

*members = \&elements;

sub element {
    my $self = shift;

    $self->elements( shift );
}

*member   = \&element;
*has      = \&element;
*contains = \&element;

sub each {
    my $self = shift;

    my ($k, $e) = each %{ $self->{'elements'} };

    return $e;
}

sub _clone {
    my $self     = shift;
    my $original = shift;

    $self->{'universe'} = $original->{'universe'};

    $self->{'null'    } = $original->{'null'    };

    $self->_insert( $original->{'elements'} );
}

sub clone {
    my $self  = shift;
    my $clone = (ref $self)->new;

    $clone->_clone( $self );

    return $clone;
}

*copy = \&clone;

sub _union ($$) {
    my ($this, $that) = @_;

    my $this_universe = $this->universe;

    return (undef,          1, undef)
	unless $this_universe == $that->universe;

    return ($this->clone,   0, ref $this)
	if $that->is_null;

    return ($that->clone,   0, ref $that)
	if $this->is_null;

    return ($this_universe, 1, ref $this)
	if $this->is_universal || $that->is_universal;

    my $union = $this->clone;

    $union->insert( $that->elements );

    return ($union, $union->is_universal, ref $this);
}

sub _union_overload {
    my ($this, $that) = _binary_underload( \@_ );

    my ($union, $is_universal, $class) = $this->_union( $that );

    return $union;
}

sub union {
    my $self = shift;

    my $union = $self->clone;

    my $is_universal;
    my $class;

    foreach my $next ( @_ ) {
	unless ($next->is_null) {
	    ($union, $is_universal, $class) = $union->_union( $next );

	    last if $is_universal;
	}
    }

    $union = $self
	if $union->size == $self->size;

    return $union;
}

sub _intersection ($$) {
    my $this = shift;
    my $that = shift;

    return (undef,        1)
	unless $this->universe == $that->universe;

    return ($this->null,  1)
	if $this->is_null || $that->is_null;

    return ($this->clone, 0)
	if $that->is_universal;

    return ($that->clone, 0)
	if $this->is_universal;

    my $intersection = $this->clone;

    my %intersection = _make_elements $intersection->elements;

    delete @intersection{ $that->elements };

    $intersection->delete( values %intersection );

    return ($intersection, $intersection->is_null);
}

sub _intersection_overload {
    my ($this, $that) = _binary_underload( \@_ );

    my ($intersection) = $this->_intersection( $that );

    return $intersection;
}

sub intersection {
    my $self = shift;

    my $intersection = $self->clone;

    foreach my $next ( @_ ) {
	unless ($next->is_universal) {
	    ($intersection, my $is_null) =
		$intersection->_intersection( $next );

	    last if $is_null;
	}
    }

    $intersection = $self
	if $intersection->size == $self->size;

    return $intersection;
}

sub _difference ($$) {
    my $this = shift;
    my $that = shift;

    return undef,       unless $this->universe == $that->universe;

    return $this->null  if $this->is_null || $that->is_universal;
    return $this->clone if $that->is_null;

    my $difference = $this->clone;

    my %that = _make_elements $that->elements;

    $difference->delete( values %that );

    return $difference;
}

sub _difference_overload {
    my ($this, $that) = _binary_underload( \@_ );

    return $this->_difference( $that );
}

sub difference {
    my $this = shift;

    return $this->null  if $this->is_null;

    return $this->clone unless @_;

    my $that = shift;

    $that = $that->union( @_ );

    return undef unless defined $that;

    return $this->null if $that->is_universal;

    my $difference = $this->_difference( $that );

    $difference = $this
	if $difference->size == $this->size;

    return $difference;
}

sub _symmetric_difference ($$) {
    my $this = shift;
    my $that = shift;

    return (undef,        1) unless $this->universe == $that->universe;

    return $that->clone      if $this->is_null;
    return $this->clone      if $that->is_null;

    return $that->complement if $this->is_universal;
    return $this->complement if $that->is_universal;

    my $symmetric_difference = $this->clone;

    $symmetric_difference->invert( $that->elements );

    $symmetric_difference = $this
	if $symmetric_difference->size == $this->size;

    return $symmetric_difference;
}

sub _symmetric_difference_overload {
    my ($this, $that ) = _binary_underload( \@_ );

    return $this->_symmetric_difference( $that );
}

sub symmetric_difference {
    my $this = shift;

    my $symmetric_difference = $this->clone;

    foreach my $next ( @_ ) {
	$symmetric_difference->invert( $next->elements );
    }

    return $symmetric_difference;
}

*symmdiff = \&symmetric_difference;

sub _complement {
    my $self       = shift;
    my $complement = (ref $self)->new( $self->universe->elements );

    $complement->delete( $self->elements );

    return $complement;
}

sub _complement_overload {
    _unary_underload( \@_ );

    my $self = shift;

    return $self->_complement;
}

sub complement {
    my $self = shift;

    return $self->_complement;
}

sub _unique {
    my $universe = $_[0]->universe;
    my %frequency;

    for my $set ( @_ ) {
	if ($set->universe == $universe) {
	    foreach my $element ( keys %{ $set->{'elements'} } ) {
		$frequency{ $element }++;
	    }
	} else {
	    return (ref $_[0])->new();
	}
    }

    return (ref $_[0])->new(grep { $frequency{ $_ } == 1 } keys %frequency);
}

sub _unique_overload {
    my ($this, $that) = _binary_underload( \@_ );

    return $this->_unique( $that );
}

sub unique {
    my $this = shift;

    return $this->_unique( @_ );
}

sub is_universal {
    my $self = shift;

    return $self->size == $self->universe->size;
}

sub is_null {
    my $self = shift;

    return $self->size == 0;
}

sub null {
    my $self = shift;

    return $self->universe->null;
}

sub _compare {
    my $a = shift;
    my $b = shift;

    return "$a" eq "$b" ? 'equal' : 'different';
}

sub compare {
    my $a = shift;
    my $b = shift;

    return _compare("$a", "$b")
	unless ref $a && $a->isa(__PACKAGE__) &&
	       ref $b && $b->isa(__PACKAGE__);

    return 'disjoint universes' unless $a->universe == $b->universe;

    my $c = $a->intersection($b);

    my $na = $a->size;
    my $nb = $b->size;
    my $nc = $c->size;

    return 'proper superset' if $na && $nb == 0;
    return 'proper subset'   if $na == 0 && $nb;
    return 'disjoint'        if $na && $nb && $nc == 0;
    return 'equal'           if $na == $nc && $nb == $nc;
    return 'proper superset' if $nb == $nc;
    return 'proper subset'   if $na == $nc;
    return 'proper intersect';
}

sub is_disjoint {
    my $a = shift;
    my $b = shift;

    return $a->compare($b) =~ /^disjoint( universes)?$/;
}

sub is_equal {
    my $a = shift;
    my $b = shift;

    return $a->compare($b) eq 'equal';
}

sub is_proper_subset {
    my $a = shift;
    my $b = shift;

    return $a->compare($b) eq 'proper subset';
}

sub is_proper_superset {
    my $a = shift;
    my $b = shift;

    return $a->compare($b) eq 'proper superset';
}

sub is_properly_intersecting {
    my $a = shift;
    my $b = shift;

    return $a->compare($b) eq 'proper intersect';
}

sub is_subset {
    my $a = shift;
    my $b = shift;

    my $c = $a->compare($b);

    return $c eq 'equal' || $c eq 'proper subset';
}

sub is_superset {
    my $a = shift;
    my $b = shift;

    my $c = $a->compare($b);

    return $c eq 'equal' || $c eq 'proper superset';
}

sub cmp {
    return "$_[0]" cmp "$_[1]";
}

sub have_same_universe {
    my $self     = shift;
    my $universe = $self->universe;

    foreach my $set ( @_ ) {
	return 0 unless $set->universe == $universe;
    }

    return 1;
}

sub _elements_have_reference {
    my $self     = shift;
    my $elements = shift;

    foreach my $element (@$elements) {
	return 1 if ref $element;
    }

    return 0;
}

use constant RECURSIVE_SELF => 1;
use constant RECURSIVE_DEEP => 2;

sub _elements_as_string {
    my $self    = shift;
    my $history = shift;

    my @elements = $self->elements;
    my $self_id  = _strval($self);
    my %history;

    %history = %{ $history } if defined $history;

    my $have_reference = $self->_elements_have_reference(\@elements);

    my @simple_elements;
    my @complex_elements;
    my $recursive;

    foreach my $element (@elements) {
	my $element_id = _strval($element);

	if (exists $history{ $element_id }) {
	    if ($element_id eq $self_id) {
		$recursive = RECURSIVE_SELF;
	    } else {
		$recursive = RECURSIVE_DEEP;
	    }
	} elsif (ref $element && $element->isa(__PACKAGE__)) {
	    local $history{ $element_id } = 1;
	    push @complex_elements, $element->as_string( \%history );
	} else {
	    push @simple_elements, $element;
	}
    }

    @elements =     sort @simple_elements;
    push @elements, sort @complex_elements;

    return (join($self->_element_separator, @elements),
	    $have_reference,
	    $recursive);
}

sub as_string {
    my $self = shift;

    my $string;

    if (exists $self->{'as_string'}) {
	$string = $self->{'as_string'};
    } else {
	($string, my $have_reference, my $recursive) =
	    $self->_elements_as_string(@_ ? shift :
                                            { _strval($self) => 1 });

	$string .= $self->_element_separator . "..." if $recursive;

	$string = sprintf $self->_set_format, $string;

	$self->{'as_string'} = $string unless $have_reference;
    }

    return $string;
}

sub _element_separator {
    my $self = shift;

    return $self->{'display'}->{'element_separator'}
        if exists $self->{'display'}->{'element_separator'};

    my $universe = $self->universe;

    return $universe->{'display'}->{'element_separator'}
        if exists $universe->{'display'}->{'element_separator'};

    return (ref $self)->ELEMENT_SEPARATOR;
}

sub _set_format {
    my $self = shift;

    return $self->{'display'}->{'set_format'}
        if exists $self->{'display'}->{'set_format'};

    my $universe = $self->universe;

    return $universe->{'display'}->{'set_format'}
        if exists $universe->{'display'}->{'set_format'};

    return (ref $self)->SET_FORMAT;
}

=pod

=head1 NAME

Set::Scalar::Base - base class for Set::Scalar

=head1 SYNOPSIS

B<Internal use only>.

=head1 DESCRIPTION

See the Set::Scalar documentation.

=head1 AUTHOR

Jarkko Hietaniemi <jhi@iki.fi>

=cut

1;
