package GraphViz;

use strict;
use vars qw($VERSION $name_counter);
use Carp;
use IPC::Run qw(run);
use vars qw($AUTOLOAD);

# This is incremented every time there is a change to the API
$VERSION = '0.05';


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

This modules provides an interface to layout and generate images of
directed graphs in a variety of formats (PostScript, PNG, etc.) using
the "dotneato" program from the GraphViz project
(http://www.graphviz.org/).

At the moment this is a fairly simple library. Some features of
dotneato are not currently implemented, such as graph
attributes. Feature requests are welcome!

=head1 METHODS

=cut


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
  

=head2 as_canon, as_text, as_gif etc. methods

There are a number of methods which generate input for dotneato or
output the graph in a variety of formats.

=over 4

=item as_canon

The as_canon method returns the canonical dotneato file which
corresponds to the graph. It does not layout the graph - every other
as_* method does.

  print $g->as_canon;


  # prints out something like:
  digraph test {
      node [	label = "\N" ];
      London [label=London];
      Paris [label="City of\nlurve"];
      New_York [label="New York"];
      London -> Paris;
      London -> New_York [label=Far];
      Paris -> London;
  }

=item as_text

The as_text method returns text which is a layed-out dotneato-format file.

  print $g->as_text;

  # prints out something like:
  digraph test {
      node [	label = "\N" ];
      graph [bb= "0,0,162,134"];
      London [label=London, pos="33,116", width="0.89", height="0.50"];
      Paris [label="City of\nlurve", pos="33,23", width="0.92", height="0.62"];
      New_York [label="New York", pos="123,23", width="1.08", height="0.50"];
      London -> Paris [pos="e,27,45 28,98 26,86 26,70 27,55"];
      London -> New_York [label=Far, pos="e,107,40 49,100 63,85 84,63 101,46", lp="99,72"];
      Paris -> London [pos="s,38,98 39,92 40,78 40,60 39,45"];
  }

=item as_ps

Returns a string which contains a layed-out PostScript-format file.

  print $g->as_ps;

=item as_hpgl

Returns a string which contains a layed-out HP pen plotter-format file.

  print $g->as_hpgl;

=item as_pcl

Returns a string which contains a layed-out Laserjet printer-format file.

  print $g->as_pcl;

=item as_mif

Returns a string which contains a layed-out FrameMaker graphics-format file.

  print $g->as_mif;

=item as_pic

Returns a string which contains a layed-out PIC-format file.

  print $g->as_pic;

=item as_gd

Returns a string which contains a layed-out GD-format file.

  print $g->as_gd;

=item as_gd2

Returns a string which contains a layed-out GD2-format file.

  print $g->as_gd2;

=item as_gif

Returns a string which contains a layed-out GIF-format file.

  print $g->as_gif;

=item as_jpeg

Returns a string which contains a layed-out JPEG-format file.

  print $g->as_jpeg;

=item as_png

Returns a string which contains a layed-out PNG-format file.

  print $g->as_png;

=item as_wbmp

Returns a string which contains a layed-out Windows BMP-format file.

  print $g->as_wbmp;

=item as_ismap

Returns a string which contains a layed-out HTML client-side image map
format file.

  print $g->as_ismap;

=item as_imap

Returns a string which contains a layed-out HTML server-side image map
format file.

  print $g->as_imap;

=item as_vrml

Returns a string which contains a layed-out VRML-format file.

  print $g->as_vrml;

=item as_vtx

Returns a string which contains a layed-out VTX (Visual Thought)
format file.

  print $g->as_vtx;

=item as_mp

Returns a string which contains a layed-out MetaPost-format file.

  print $g->as_mp;

=item as_fig

Returns a string which contains a layed-out FIG-format file.

  print $g->as_fig;

=item as_svg

Returns a string which contains a layed-out SVG-format file.

  print $g->as_svg;

=item as_plain

Returns a string which contains a layed-out simple-format file.

  print $g->as_plain;

=back

=cut

# Generate magic methods to save typing

sub AUTOLOAD {
  my $self = shift;
  my $type = ref($self)
    or croak "$self is not an object";
  
  my $name = $AUTOLOAD;
  $name =~ s/.*://;   # strip fully-qualified portion

  if ($name eq 'as_text') {
    $name = "as_dot";
  }

  if ($name =~ /^as_(ps|hpgl|pcl|mif|pic|gd|gd2|gif|jpeg|png|wbmp|ismap|imap|vrml|vtx|mp|fig|svg|dot|canon|plain)$/) {
    return $self->_as_generic('-T' . $1);
  }
  
  croak "Method $name not defined!";
}


# Generate the actual dot text

sub _as_debug {
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


# Call neato with the dotneato input text and any parameters

sub _as_generic {
  my $self = shift;

  my $dot = $self->_as_debug;

  my $out;
  run ['dotneato', @_], \$dot, \$out;

  return $out;
}


# Quote a node/edge name using dotneato's quoting rules

sub _quote_name {
  my $name = shift;
  $name =~ s|[ :]|_|g;
  return $name;
}


# Return the attributes of a node or edge as a dotneato attribute
# string

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
    return ' [' . (join ', ', sort @attributes) . "]";
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
