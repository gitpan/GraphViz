#!/usr/bin/perl
#
# A example which represents some XML as a tree

use strict;
use lib '..';
use GraphViz;
use XML::Twig;

my $xml = '<html><head><title>news</title></head><body>
<p>Check out the <a href="/news/">latest news</a>.</p>
<p>Under construction!!!</p></body></html>';

my $p = XML::Twig->new();
$p->parse($xml);

my $g = GraphViz->new();

graph($g, $p->root);

sub graph {
  my($g, $root) = @_;
#warn "$root $root->gi\n";

  my $label = $root->gi;
  my $colour = 'blue';
  my $shape = "ellipse";

  if ($root->is_pcdata) {
    $label = $root->text;
    $label =~ s|^\s+||;
    $label =~ s|\s+$||;
    $colour = 'black';
  } else {
#      $label = "<$label>";
      $shape = "diamond";
  }

  $g->add_node({ name => $root, label => $label, color => $colour, shape => $shape});
  foreach my $child ($root->children) {
    $g->add_edge({ from => $root, to => $child });
    graph($g, $child);
  }

}

print $g->as_png;
#print $g->as_text;
#print $g->_as_debug;

