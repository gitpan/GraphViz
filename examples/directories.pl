#!/usr/bin/perl

use strict;
use lib '..';
use IO::Dir;
use GraphViz;
use GraphViz::Small;
use GraphViz::No;

my $directory = '/home/acme/ruby/';

my $graph = GraphViz::No->new({directed => 0});

walk($directory);

sub walk {
  my($dir, $parent) = @_;
  warn "\nwalk $dir $parent\n";

  $graph->add_node($dir) unless defined $parent;

  my $d = IO::Dir->new($dir);
  foreach my $file ($d->read) {
    next if $file =~ /^\./;
    if (-f $dir . $file) {
      warn "$file in $dir\n";
      $graph->add_node($dir . $file, label => $file);
      $graph->add_edge($dir => $dir . $file);
    } elsif (-d $dir . $file) {
      warn "$file in $dir is DIR\n";
      $graph->add_node($dir . $file . '/', label => $file . '/');
      $graph->add_edge($dir => $dir . $file . '/');
      walk($dir . $file . '/', $dir);
    }
  }
  warn "\n";
}

#print $graph->_as_debug;
print $graph->as_png;


