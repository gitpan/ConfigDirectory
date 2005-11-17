#!/usr/bin/perl
# Copyright (c) 2005 Jonathan T. Rockway

package ConfigDirectory::Internal;
1;

our $VERSION=0.01;

=head1 NAME

ConfigDirectory - Modules for reading information from a hierarchy of
                  small files

=head1 VERSION

Version 0.01

=cut

# takes key file in the form /path/to/file, not root/path.to.file!
sub _internal_read_keyfile {
    my $root = shift;
    my $key = shift;
    my $keep_blank = shift;
    
    $key =~ s|\.+|/|g;
    
    my $result = open my $keyfile, "<$root/$key";
    return unless $result;

    my @lines = <$keyfile>;
    my @result;
    
    foreach(@lines){
	chomp;
	s/(^\s+|\s+$)//g;
	push(@result, $_) if ($_ || $_ eq "0" || $keep_blank);
    }

    if(wantarray){
	return @result;
    }
    else {
	return $result[0];
    }
}

# ditto.  use UNIX paths here.
sub _keyfile_exists {
    my $root = shift;
    my $key = shift;
    return -e "$root/$key"; 
}
