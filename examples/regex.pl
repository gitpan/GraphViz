#!/usr/bin/perl
#
# An example of visualising a regular expression using GraphViz::Regex

use strict;
use lib '../lib';
use GraphViz::Regex;

#my $regex = '((a{0,5}){0,5}){0,5}[c]';
#my $regex = '([ab]c)+';
my $regex = '(([abcd0-9])|(foo))';

my $graph = GraphViz::Regex->new($regex);

warn $graph->_as_debug;
print $graph->as_png;
