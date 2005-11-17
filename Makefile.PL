use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ConfigDirectory',
    AUTHOR              => 'Jonathan T. Rockway <jon-perl@jrock.us>',
    VERSION_FROM        => 'lib/ConfigDirectory/Internal.pm',
    ABSTRACT_FROM       => 'lib/ConfigDirectory/Internal.pm',
    PL_FILES            => {},
    PREREQ_PM => {
       'Exporter' => 1,		  
       'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ConfigDirectory-*' },
);
