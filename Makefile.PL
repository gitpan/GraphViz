use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
            'NAME' => 'GraphViz',
    'VERSION_FROM' => 'lib/GraphViz.pm', # finds $VERSION
       'PREREQ_PM' => { 'IPC::Run' => 0, 'Graph' => 0, 'Math::Bezier' => 0, },
            'dist' => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);