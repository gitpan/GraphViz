#!/usr/bin/perl
#
# An example of visualising a regular expression using GraphViz::Regex

use strict;
use lib '../lib';
use GraphViz::Regex_YAPE;

#my $regex = '((a{0,5}){0,5}){0,5}[c]';
#my $regex = '([ab]c)+';
#my $regex = '(([abcd0-9])|(foo))';
#my $regex = '[aeiou][^aeiou]+[aeiou]';
my $regex = 'a+b*c?d{4,5}e+?';
#my $regex = '(a+b+c+)*foo[a]bar[q]a+b+(foo|bar)';
#my $regex = '(a|b)';
my $graph = GraphViz::Regex_YAPE->new($regex);

warn $graph->_as_debug;
print $graph->as_png;

__END__
use YAPE::Regex;

my $parser = YAPE::Regex->new('[aeiou][^aeiou]+[aeiou]');
$parser->parse;
#print $parser->display;
use Data::Dumper;
print Dumper($parser->root);
