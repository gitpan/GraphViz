package GraphViz::Regex_YAPE;

use strict;
use vars qw($VERSION);
use Carp;
use Config;
use lib '../..';
use lib '..';
use GraphViz;
use YAPE::Regex;

# This is incremented every time there is a change to the API
$VERSION = '0.01';

=head1 NAME

GraphViz::Regex_YAPE - Visualise a regular expression

=head1 SYNOPSIS

  use GraphViz::Regex_YAPE;

  my $regex = '(([abcd0-9])|(foo))';

  my $graph = GraphViz::Regex_YAPE->new($regex);
  print $graph->as_png;

=head1 DESCRIPTION

This module attempts to visualise a Perl regular
expression. Understanding regular expressions is tricky at the best of
times, and regexess almost always evolve in ways unforseen at the
start. This module aims to visualise a regex as a graph in order to
make the structure clear and aid in understanding the regex.

The graph visualises how the Perl regular expression engine attempts
to match the regex. Simple text matches or character classes are
represented by.box-shaped nodes. Alternations are represented by a
diamond-shaped node which points to the alternations. Repetitions are
represented by self-edges with a label of the repetition type (the
nodes being repeated are pointed to be a full edge, a dotted edge
points to what to match after the repetition). Matched patterns (such
as $1, $2, etc.) are represented by a 'Capture start' .. 'Capture end'
node pair.

This module is an alternative to the GraphViz::Regex module which uses
the YAPE::Regex module by Jeff Pinyan. It is probably slightly more
portable than GraphViz::Regex, which uses the Perl debugger. Which do
you prefer?

This uses the GraphViz module to draw the graph.

=head1 METHODS

=head2 new

This is the constructor. It takes one mandatory argument, which is a
string of the regular expression to be visualised. A GraphViz object
is returned.

  my $graph = GraphViz::Regex_YAPE->new($regex);

=cut


sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $regex = shift;

  return _init($regex);
}


=head2 as_*

The regex can be visualised in a number of different graphical
formats. Methods include as_ps, as_hpgl, as_pcl, as_mif, as_pic,
as_gd, as_gd2, as_gif, as_jpeg, as_png, as_wbmp, as_ismap, as_imap,
as_vrml, as_vtx, as_mp, as_fig, as_svg. See the GraphViz documentation
for more information. The two most common methods are:

  # Print out a PNG-format file
  print $g->as_png;

  # Print out a PostScript-format file
  print $g->as_ps;

=cut

sub _init {
  my $regex = shift;

  my $g = GraphViz->new();

  my $parser = YAPE::Regex->new($regex);
  $parser->parse;

  my $root = $parser->root;
  use Data::Dumper;
  warn Dumper($root);

  _init_aux($g, $root);

  return $g;
}

sub _init_aux {
  my($g, $root) = @_;

  my $first = $root;
  my $last;

  my $type = $root->type;

  if ($type eq 'group') {
    my @nodes = map {_init_aux($g, $_)} @{$root->{CONTENT}};
    my $previous = shift @nodes;
    $first = $previous->[0];
    foreach my $node (@nodes) {
      $g->add_edge($previous->[1] => $node->[0]);
      $previous = $node;
    }
    push @nodes, $previous;
    $last = $nodes[-1]->[1];
  } elsif ($type eq 'capture') {
    my @nodes = map {_init_aux($g, $_)} @{$root->{CONTENT}};
    my $start = $g->add_node(label => "Capture start");
    my $end = $g->add_node(label => "Capture end");
    unshift @nodes, [$start, $start];
    push @nodes, [$end, $end];
    my $previous = shift @nodes;
    $first = $previous->[0];
    foreach my $node (@nodes) {
      $g->add_edge($previous->[1] => $node->[0]);
      $previous = $node;
    }
    $last = $nodes[-1]->[1];
  } elsif ($type =~ /^class|text|anchor/) {
    $last = $g->add_node($root, label => $root->text, shape => 'box');
  } else {
    $last = $g->add_node($root, label => $type);
  }

  my $quant = $root->quant;
  if ($quant) {
    $g->add_edge($first => $first, label => $quant);
  }

  return [$first, $last];
}

=head1 AUTHOR

Leon Brocard E<lt>F<acme@astray.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2000-1, Leon Brocard

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut

1;
