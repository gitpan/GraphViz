#!/usr/bin/perl -w

use strict;
use lib '../lib';
use GraphViz::Parse::Yapp;

my $g = GraphViz::Parse::Yapp->new('Yapp.output');
$g->as_png("yapp.png");


