package GraphViz;

use warnings;
use strict;
use vars qw($AUTOLOAD $VERSION);

use Carp;
use Graph::Directed;
use Math::Bezier;
use IPC::Run qw(run);

# This is incremented every time there is a change to the API
$VERSION = '0.10';


=head1 NAME

GraphViz - Interface to the GraphViz graphing tool

=head1 SYNOPSIS

  use GraphViz;

  my $g = GraphViz->new();

  $g->add_node('London');
  $g->add_node('Paris', label => 'City of\nlurve');
  $g->add_node('New York');

  $g->add_edge('London' => 'Paris');
  $g->add_edge('London' => 'New York', label => 'Far');
  $g->add_edge('Paris' => 'London');


  print $g->as_png;


=head1 DESCRIPTION

This module provides an interface to layout and image generation of
directed and undirected graphs in a variety of formats (PostScript,
PNG, etc.) using the "dot" and "neato" programs from the GraphViz
project (http://www.graphviz.org/).

=head2 What is a graph?

A (undirected) graph is a collection of nodes linked together with
edges.

A directed graph is the same as a graph, but the edges have a
direction.

=head2 What is GraphViz?

This module is an interface to the GraphViz toolset
(http://www.graphviz.org/). The GraphViz tools provide automatic graph
layout and drawing. This module simplifies the creation of graphs and
hides some of the complexity of the GraphViz module.

Laying out graphs in an aesthetically-pleasing way is a hard problem -
there may be multiple ways to lay out the same graph, each with their
own quirks. GraphViz luckily takes part of this hard problem and does
a pretty good job in a couple of seconds for most graphs.

=head2 Why should I use this module?

Observation aids comprehension. That is a fancy way of expressing
that popular faux-Chinese proverb: "a picture is worth a thousand
words".

Text is not always the best way to represent anything and everything
to do with a computer programs. Pictures and images are easier to
assimilate than text. The ability to show a particular thing
graphically can aid a great deal in comprehending what that thing
really represents.

Diagrams are computationally efficient, because information can be
indexed by location; they group related information in the same
area. They also allow relations to be expressed between elements
without labeling the elements.

A friend of mine used this to his advantage when trying to remember
important dates in computer history. Instead of sitting down and
trying to remember everything, he printed over a hundred posters (each
with a date and event) and plastered these throughout his house. His
spatial memory is still so good that asked last week (more than a year
since the experiment) when Lisp was invented, he replied that it was
upstairs, around the corner from the toilet, so must have been around
1958.

Spreadsheets are also a wonderfully simple graphical representation of
computational models.

=head1 METHODS

=cut


=head2 new

This is the constructor. It currently takes one attribute, 'directed',
which defaults to 1 (true) - this specifies directed (tree-like)
graphs. Setting this to zero produces undirected graphs, which are
layed out differently.

  my $g = GraphViz->new();
  my $g = GraphViz->new(directed => 0);

=cut


sub new {
  my $proto = shift;
  my $config = shift;
  my $class = ref($proto) || $proto;
  my $self = {};

  # Cope with the old hashref format
  if (ref($config) ne 'HASH') {
    my %config;
    %config = ($config, @_) if @_;
    $config = \%config;
  }

  $self->{NODES} = {};
  $self->{EDGES} = [];
  $self->{GRAPH} = Graph::Directed->new();

  if (exists $config->{directed}) {
      $self->{DIRECTED} = $config->{directed};
  } else {
      $self->{DIRECTED} = 1; # default to directed
  }

  bless($self, $class);
  return $self;
}


=head2 add_node

A graph consists of at least one node. All nodes have a name attached
which uniquely represents that node.

The add_node method creates a new node and optionally assigns it
attributes.

The simplest form is used when no attributes are required, in which
the string represents the name of the node:

  $g->add_node('Paris');

Various attributes are possible: "label" provides a label for the node
(the label defaults to the name if none is specified). The label can
contain embedded newlines with '\n', as well as '\c', '\l', '\r' for
center, left, and right justified lines:

  $g->add_node('Paris', label => 'City of\nlurve');

Note that multiple attributes can be specified. Other attributes
include:

=over 4

=item height, width

sets the minimum height or width

=item shape

sets the node shape. This can be one of: 'record', 'plaintext',
'ellipse', 'circle', 'egg', 'triangle', 'box', 'diamond', 'trapezium',
'parallelogram', 'house', 'hexagon', 'octagon'

=item fontsize

sets the label size in points

=item fontname

sets the label font family name

=item color

sets the outline colour, and the default fill colour if the 'style' is
'filled' and 'fillcolor' is not specified

A colour value may be "h,s,v" (hue, saturation, brightness) floating
point numbers between 0 and 1, or an X11 color name such as 'white',
'black', 'red', 'green', 'blue', 'yellow', 'magenta', 'cyan', or
'burlywood'

=item fillcolor

sets the fill colour when the style is 'filled'. If not specified, the
'fillcolor' when the 'style' is 'filled' defaults to be the same as
the outline color

=item style

sets the style of the node. Can be one of: 'filled', 'solid',
'dashed', 'dotted', 'bold', 'invis'

=item URL

sets the url for the node in image map and PostScript files. The
string '\N' value will be replaced by the node name. In PostScript
files, URL information is embedded in such a way that Acrobat
Distiller creates PDF files with active hyperlinks

=back

If you wish to add an anonymous node, that is a node for which you do
not wish to generate a name, you may use the following form, where the
GraphViz module generates a name and returns it for you. You may then
use this name later on to refer to this node:

  my $nodename = $g->add_node('label' => 'Roman city');

Nodes can be clustered together with the "cluster" attribute, which is
drawn by having a labelled rectangle around all the nodes in a
cluster.

  $g->add_node('London', cluster => 'Europe');
  $g->add_node('Amsterdam', cluster => 'Europe');

Also, nodes can consist of multiple parts (known as ports). This is
implemented by passing an array reference as the label, and the parts
are displayed as a label. GraphViz has a much more complete port
system, this is just a simple interface to it. See the 'from_port' and
'to_port' attributes of add_edge:

  $g->add_node('London', label => ['Heathrow', 'Gatwick']);

=cut

sub add_node {
  my $self = shift;
  my $node = shift;

  # Cope with the new simple notation
  if (ref($node) ne 'HASH') {
    my $name = $node;
    my %node;
    if (@_ % 2 == 1) {
      # No name passed
      %node = ($name, @_);
    } else {
      # Name passed
      %node = (@_, name => $name);
    }
    $node = \%node;
  }

  $self->add_node_munge($node) if $self->can('add_node_munge');

  # The _code attribute is our internal name for the node
  $node->{_code} = $self->_quote_name($node->{name});

  if (not exists $node->{name}) {
    $node->{name} = $node->{_code};
  }

  if (not exists $node->{label}) {
    $node->{label} = $node->{name};
  }

  $node->{_label} =  $node->{label};

  # Deal with ports
  if (ref($node->{label}) eq 'ARRAY') {
    $node->{shape} = 'record'; # force a record
    my $nports = 0;
    $node->{label} = join '|', map
      { $_ =~ s#([|<>\[\]{}"])#\\$1#g; '<port' . $nports++ . '>' . $_ }
      (@{$node->{label}});
  }

  $self->{NODES}->{$node->{name}} = $node; # should remove!
  $self->{CODES}->{$node->{_code}} = $node->{name};
  $self->{GRAPH}->add_vertex($node->{name});

  foreach my $key (keys %$node) {
    $self->{GRAPH}->set_attribute($key, $node->{name}, $node->{$key});
  }

  return $node->{name};
}


=head2 add_edge

Edges are directed (or undirected) links between nodes. This method
creates a new edge between two nodes and optionally assigns it
attributes.

The simplest form is when now attributes are required, in which case
the nodes from and to which the edge should be are specified. This
works well visually in the program code:

  $g->add_edge('London' => 'Paris');

Attributes such as 'label' can also be used. This specifies a label
for the edge.  The label can contain embedded newlines with '\n', as
well as '\c', '\l', '\r' for center, left, and right justified lines.

  $g->add_edge('London' => 'New York', label => 'Far');

Note that multiple attributes can be specified. Other attributes
include:

=over 4

=item minlen

sets an integer factor that applies to the edge length (ranks for
normal edges, or minimum node separation for flat edges)

=item weight

sets the integer cost of the edge. Values greater than 1 tend to
shorten the edge. Weight 0 flat edges are ignored for ordering
nodes

=item fontsize

sets the label type size in points

=item fontname

sets the label font family name

=item fontcolor

sets the label text colour

=item color

sets the line colour for the edge

A colour value may be "h,s,v" (hue, saturation, brightness) floating
point numbers between 0 and 1, or an X11 color name such as 'white',
'black', 'red', 'green', 'blue', 'yellow', 'magenta', 'cyan', or
'burlywood'

=item style

sets the style of the node. Can be one of: 'filled', 'solid',
'dashed', 'dotted', 'bold', 'invis'


=item dir

sets the arrow direction. Can be one of: 'forward', 'back', 'both',  'none'

=item tailclip, headclip

when set to false disables endpoint shape clipping

=item arrowhead, arrowtail

sets the type for the arrow head or tail. Can be one of: 'none',
'normal', 'inv', 'dot', 'odot', 'invdot', 'invodot.'

=item arrowsize

sets the arrow size: (norm_length=10,norm_width=5,
inv_length=6,inv_width=7,dot_radius=2)

=item headlabel, taillabel

sets the text for port labels. Note that labelfontcolor,
labelfontname, labelfontsize are also allowed

=item labeldistance, port_label_distance

sets the distance from the edge / port to the label. Also labelangle

=item decorateP

if set, draws a line from the edge to the label

=item samehead, sametail

if set aim edges having the same value to the same port, using the
average landing point

=item constraint

if set to false causes an edge to be ignored for rank assignment

=back

Additionally, adding edges between ports of a node is done via the
'from_port' and 'to_port' parameters, which currently takes in the
offset of the port (ie 0, 1, 2...).

  $g->add_edge('London' => 'Paris', from_port => 0);

=cut

sub add_edge {
  my $self = shift;
  my $edge = shift;

  # Also cope with simple $from => $to
  if (ref($edge) ne 'HASH') {
    my $from = $edge;
    my %edge = (from => $from, to => shift, @_);
    $edge = \%edge;
  }

  $self->add_edge_munge($edge) if $self->can('add_edge_munge');

  if (not exists $edge->{from} or not exists $edge->{to}) {
    carp("GraphViz add_edge: 'from' or 'to' parameter missing!");
    return;
  }

  push @{$self->{EDGES}}, $edge; # should remove!

  $self->{GRAPH}->add_edge($edge->{from} => $edge->{to});

  foreach my $key (keys %$edge) {
    $self->{GRAPH}->set_attribute($key, $edge->{from}, $edge->{to}, $edge->{$key});
  }

}


=head2 as_canon, as_text, as_gif etc. methods

There are a number of methods which generate input for dot / neato or
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

The as_text method returns text which is a layed-out dot / neato-format file.

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

  return if $name =~ /DESTROY/;

  if ($name eq 'as_text') {
    $name = "as_dot";
  }

  if ($name =~ /^as_(ps|hpgl|pcl|mif|pic|gd|gd2|gif|jpeg|png|wbmp|ismap|imap|vrml|vtx|mp|fig|svg|dot|canon|plain)$/) {
    return $self->_as_generic('-T' . $1);
  }

  croak "Method $name not defined!";
}


# Undocumented feature: return a Graph object
sub as_graph {
  my($self, $conf) = @_;
  my $graph = $self->{GRAPH};

  return $self->_parse_dot($self->_as_debug);
}


sub _parse_dot {
  my($self, $dot) = @_;
  my $graph = $self->{GRAPH};

  my $out;
  my $program = $self->{DIRECTED} ? 'dot' : 'neato';

  run [$program, '-Tplain'], \$dot, \$out;

  my($aspect, $bbw, $bbh);

  foreach my $line (split /\n/, $out) {
#    print "# $line\n";

    my($type, @values) = split /\s+/, $line;
    if ($type eq 'graph') {
      ($aspect, $bbw, $bbh) = @values;
    } elsif ($type eq 'node') {
      my($node, $x, $y, $w, $h) = @values;
      $x /= $bbw;
      $y /= $bbh;
      $w /= $bbw;
      $h /= $bbh;
      $node = $self->{CODES}->{$node};
#      print "#  $node  ($x, $y) x ($w, $h)\n";
      $graph->set_attribute('x', $node, $x);
      $graph->set_attribute('y', $node, $y);
      $graph->set_attribute('w', $node, $w);
      $graph->set_attribute('h', $node, $h);
    } elsif ($type eq 'edge') {
      my($from, $to, $n, @points) = @values;

      $from = $self->{CODES}->{$from};
        $to = $self->{CODES}->{$to};

      @points = splice(@points, 0, $n * 2);

      my @newpoints;

      while (@points) {
	my ($x, $y) = splice(@points, 0, 2);
	$x /= $bbw;
	$y /= $bbh;
	push @newpoints, $x, $y;
      }

      my $bezier = Math::Bezier->new(@newpoints);
#      print "#  $from->$to: @newpoints\n";
      $graph->set_attribute('bezier', $from, $to, $bezier);
    }
#    next unless $type eq 'node';
  }

  return $graph;
}


# Return the main dot text
sub _as_debug {
  my $self = shift;

  my $dot;

  my $graph_type = $self->{DIRECTED} ? 'digraph' : 'graph';

  $dot .= "$graph_type test {\n";

  my %clusters = ();
  my %clusters_edge = ();

  my $arrow = $self->{DIRECTED} ? ' -> ' : ' -- ';

  # Add all the nodes
  foreach my $name (sort keys %{$self->{NODES}}) {
    my $node = $self->{NODES}->{$name};

    # Note all the clusters
    if (exists $node->{cluster}) {
      push @{$clusters{$node->{cluster}}}, $name;
      next;
    }

    $dot .= "\t" . $node->{_code} . _attributes($node) . ";\n";
  }

  # Add all the edges
  foreach my $edge (sort { $a->{from} cmp $b->{from} || $a->{to} cmp $b->{to} } @{$self->{EDGES}}) {

    my $from = $self->{NODES}->{$edge->{from}}->{_code};
    my $to = $self->{NODES}->{$edge->{to}}->{_code};

    # Deal with ports
    if (exists $edge->{from_port}) {
      $from = '"' . $from . '"' . ':port' . $edge->{from_port};
    }
    if (exists $edge->{to_port}) {
      $to = '"' . $to . '"' . ':port' . $edge->{to_port};
    }

    if (exists $self->{NODES}->{$from} && exists $self->{NODES}->{$from}->{cluster}
        && exists $self->{NODES}->{$to} && exists $self->{NODES}->{$to}->{cluster} &&
	$self->{NODES}->{$from}->{cluster} eq $self->{NODES}->{$to}->{cluster}) {

      $clusters_edge{$self->{NODES}->{$from}->{cluster}} .= "\t\t" . $from . $arrow . $to . _attributes($edge) . ";\n";
    } else {
      $dot .= "\t" . $from . $arrow . $to . _attributes($edge) . ";\n";
    }
  }

  foreach my $cluster (sort keys %clusters) {
    my $label = _attributes({ label => $cluster});
    $label =~ s/^\s\[//;
    $label =~ s/\]$//;

    $dot .= "\tsubgraph cluster_" . $self->_quote_name($cluster) . " {\n";
    $dot .= "\t\t$label;\n";
    $dot .= join "", map { "\t\t" . $self->{NODES}->{$_}->{_code} . _attributes($self->{NODES}->{$_}) . ";\n"; } (@{$clusters{$cluster}});
    $dot .= $clusters_edge{$cluster} if exists $clusters_edge{$cluster};
    $dot .= "\t}\n";
  }

  $dot .= "}\n";

  return $dot;
}


# Call dot/neato with the input text and any parameters

sub _as_generic {
  my $self = shift;

  my $dot = $self->_as_debug;
  my $out;
  my $program = $self->{DIRECTED} ? 'dot' : 'neato';

  run [$program, @_], \$dot, \$out;

  return $out;
}


# Quote a node/edge name using dotneato's quoting rules

sub _quote_name {
  my($self, $name) = @_;
  my $realname = $name;

  return $self->{_QUOTE_NAME_CACHE}->{$name} if exists $self->{_QUOTE_NAME_CACHE}->{$name};

  if (!defined($name) || $name !~ /^[a-z]+$/) {
    # name contains weird characters - let's make up a name for it
    $name = 'node' . ++$self->{_NAME_COUNTER};
  }

  $self->{_QUOTE_NAME_CACHE}->{$realname} = $name if defined $realname;

#  warn "# $realname -> $name\n";

  return $name;
}


# Return the attributes of a node or edge as a dotneato attribute
# string

sub _attributes {
  my $thing = shift;

  my @attributes;

  foreach my $key (keys %$thing) {
    next if $key =~ /^_/;
    next if $key =~ /^(to|from|name|cluster|from_port|to_port)$/;

    my $value = $thing->{$key};
    $value = '"' . $value . '"';
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


=head1 NOTES

Older versions of GraphViz used a slightly different syntax for node
and edge adding (with hash references). The new format is slightly
clearer, although for the moment we support both. Use the new, clear
syntax, please.

=head1 AUTHOR

Leon Brocard E<lt>F<acme@astray.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2000-1, Leon Brocard

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut

1;
