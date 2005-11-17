package ConfigDirectory::Local;

use warnings;
use strict;
use ConfigDirectory::Internal;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(read_local_key read_local_key_keepblank);

=head1 NAME

ConfigDirectory::Local - Read attributes pertaining to a file

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 EXPORT

read_local_key read_local_key_keepblank

=cut

=head1 FUNCTIONS

=head2 read_local_key
     
     read_local_key(root, key, [top])

Starting at directory "root", will look for a file named "key" in each
parent directory of "root" and will return the contents of the first
matching file in the form of an array of non-empty lines stripped of
trailing and leading space, or the only first line in scalar context.

The optional argument "top" specifies where to stop looking.  If
"root" is ever below "top", the serach will stop and undefined will be
returned.  The default value for "top" is "/".

For example, in /path/to/some/files, there exists a file named
"key1". The subdirectories of /path/to/some/files are all empty (at
least of files named "key1").

     read_local_key("/path/to/some/files", "key1", "/path/to");
     read_local_key("/path/to/some/files/and/other/things", "key1");

In this case, both expressions are equal.

=head2 read_local_key_keepblank

Same as read_local_key, but maintains blank lines in the original file

=cut

sub read_local_key {
    return _internal_read_local_key(shift(),shift(),shift(),0);
}

sub read_local_key_keepblank {
    return _internal_read_local_key(shift(),shift(),shift(),1);
}

## TODO: named arguments
sub _internal_read_local_key {
    my $start_dir = shift;  # where to start looking
    my $key = shift;        # what we're looking for
    my $upper_dir = shift;  # as high as we'll go
    my $keep_blank = shift;

    if(!$upper_dir){
	$upper_dir = "/"; # assume / if not specified
    }
   

    # relative directories cause confusion
    my $PWD = ($ENV{PWD} or `pwd`);
    chomp $PWD;
    
    #print {*STDERR} "PWD is $PWD\n";
    my $LEADING_SLASH_REGEX = "(^[^/])|([.][/])";

    if($start_dir =~ /$LEADING_SLASH_REGEX/){
	$start_dir = "$PWD/$start_dir";
    }
    if($upper_dir =~ /$LEADING_SLASH_REGEX/){
	$upper_dir = "$PWD/$upper_dir";
    }
    
    # fix slashes
    $start_dir =~ s|/+|/|g; 
    $upper_dir =~ s|/+|/|g;

    # die if there's weird directory stuff going on
    if($start_dir =~ /\.\./ || $upper_dir =~ /\.\./){
	die "Double dots are not allowed.";
    }

    # change /path/./another -> /path/another
    $start_dir =~ s|(.+)/\./(.+)|$1/$2|g;
    $upper_dir =~ s|(.+)/\./(.+)|$1/$2|g;
    
    # now make sure things exist
    if(!-e $start_dir) {
	die "Starting directory $start_dir does not exist";
    }

    if(!defined $key){
	die "undefined key";
    }
    
    if(index($start_dir, $upper_dir) != 0){
	return;
	#die "$start_dir does not contain $upper_dir";
    }
    
    # let's do this

    my @result = ConfigDirectory::Internal::_internal_read_keyfile($start_dir,
								   $key,
								   $keep_blank);

    my $exists = ConfigDirectory::Internal::_keyfile_exists($start_dir,$key);

    if(!@result && $exists){
	return;
    }

    if(!@result && $start_dir =~ /(.+)\//){
	@result = _internal_read_local_key($1, $key, $upper_dir, $keep_blank);
    }
    
    if(wantarray){
	return @result;
    }

    return $result[0];    
}


=head1 AUTHOR

Jonathan T. Rockway, <jon-perl@jrock.us>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-configdirectory-local@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ConfigDirectory-Local>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Jonathan T. Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of ConfigDirectory::Local
