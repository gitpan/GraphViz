package GraphViz;

use strict;
use vars qw($VERSION $name_counter);
use Carp;

# This is incremented every time there is a change to the API
$VERSION = '0.04';


=head1 NAME

GraphViz - Interface to the GraphViz graphing tool

=head1 SYNOPSIS

  use GraphViz;

  my $g = GraphViz->new();

  $g->add_node({ name => 'London'});
  $g->add_node({ name => 'Paris', label => 'City of\nlurve'});
  $g->add_node({ name => 'New York'});

  $g->add_edge({ from => 'London',
	           to => 'Paris',});

  $g->add_edge({ from => 'London',
	           to => 'New York',
	        label => 'Far'});

  $g->add_edge({ from => 'Paris',
	           to => 'London',});


  print $g->as_text;

Prints the following:

  digraph test {
  	London -> Paris;
  	London -> New_York [label=Far];
  	Paris -> London;
  	London [label=London];
  	New_York [label="New York"];
  	Paris [label="City of\nlurve"];
  }


=head1 DESCRIPTION

This provides an object-orientated interface to generating the ".dot"
files needed by the "dotneato" program in the GraphViz project
(http://www.graphviz.org/). It constructs a file which can then be
used to draw directed graphs in a variety of formats (Postscript, GIF,
etc.)

At the moment this is a very simple library (it is a very simple
format). Some features of the format are not currently implemented,
such as graph attributes. Feature requests are welcome!

I am not going to document the ".dot" file format: the node and edge
attributes are available in the "dot" manpage, so you should check
that out if you want to use non-default attributes.

=head1 METHODS

=head2 new

This is the constructor. It currently takes no arguments:

  my $g = GraphViz->new();

=cut


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};

  $self->{NODES} = {};
  $self->{EDGES} = [];

  bless($self, $class);
  return $self;
}


=head2 add_node

A graph consists of at least one node. This method creates a new node
and assigns it attributes. Various attributes are possible: "name"
suggests a name for the node (if you do not supply one, one is
generated for you and returned), "label" provides a label for the node
(the label defaults to the name if none is specified). See the "dot"
manpage under "NODE ATTRIBUTES" for others.

  $g->add_node({ name => 'Paris', label => 'City of\nlurve'});

=cut

sub add_node {
  my $self = shift;
  my $node = shift;

  if (not exists $node->{name}) {
    $node->{name} = 'node' . ++$name_counter;
  }

  if (not exists $node->{label}) {
    $node->{label} = $node->{name};
  }

  $self->{NODES}->{$node->{name}} = $node;

  return $node->{name};
}


=head2 add_edge

Edges are directed links between nodes. This method creates a new edge
between two nodes and optionally assigns it attributes. Two mandatory
parameters are 'from' and 'to', which indicate the node names that the
edge connects. Optional attributes such as 'label' are also available
(see the "dot" manpage under the "EDGE ATTRIBUTES" for others).

  $g->add_edge({ from => 'London',
	           to => 'New York',
	        label => 'Far'});

=cut

sub add_edge {
  my $self = shift;
  my $node = shift;

  if (not exists $node->{from} or not exists $node->{to}) {
    carp("GraphViz add_edge: 'from' or 'to' parameter missing!");
    return;
  }

#  if (not exists $self->{NODES}->{$node->{from}}) {
#    warn "From node $node->{from} doesn't exist!";
#  }

#  if (not exists $self->{NODES}->{$node->{to}}) {
#    warn "To node $node->{to} doesn't exist!";
#  }

  push @{$self->{EDGES}}, $node;
}
  

sub as_text {
  my $self = shift;

  my $dot;

  $dot .= "digraph test {\n";

  foreach my $edge (@{$self->{EDGES}}) {
    $dot .= "\t" . _quote_name($edge->{from}) . " -> " . _quote_name($edge->{to}) . _attributes($edge) . ";\n";
  }

  foreach my $name (sort keys %{$self->{NODES}}) {
    my $node = $self->{NODES}->{$name};
    $name = _quote_name($name);
    $dot .= "\t$name" . _attributes($node) . ";\n";
  }

  $dot .= "}\n";

  return $dot;
}

sub _quote_name {
  my $name = shift;
  $name =~ s|[ :]|_|g;
  return $name;
}

sub _attributes {
  my $thing = shift;

  my @attributes;

  foreach my $key (keys %$thing) {
    next if $key eq 'to' or $key eq 'from' or $key eq 'name';
    my $value = $thing->{$key};
    $value = '"' . $value . '"' if $value =~ /\W/;
    $value =~ s|\n|\\n|g;
    $value = '""' if not defined $value;
    push @attributes, "$key=$value";
  }

  if (@attributes) {
    return ' [' . (join ', ', @attributes) . "]";
  } else {
    return "";
  }
}

=head1 AUTHOR

Leon Brocard E<lt>F<acme@astray.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2000, Leon Brocard

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut

1;
