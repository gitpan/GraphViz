#!/usr/bin/perl -w

use strict;
use lib '../lib';
use GraphViz::Parse::Yacc;

my $g = GraphViz::Parse::Yacc->new('perly.output');
$g->as_png("yacc.png");
print $g->as_text();


