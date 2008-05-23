package Carp::POE;

use strict;
use warnings;
use Carp ();
use POE::Session;
use base qw(Exporter);

our @EXPORT      = qw(confess croak carp);
our @EXPORT_OK   = qw(cluck verbose);
our @EXPORT_FAIL = qw(verbose);
our $VERSION     = '0.01';

# from POE::Session
my ($file, $line) = (CALLER_FILE, CALLER_LINE);

sub export_fail { Carp::export_fail(@_) }
sub confess     { die Carp::longmess(@_) . "\n" }
sub cluck       { warn Carp::longmess(@_) . "\n" }

sub croak {
    if (_is_handler()) {
        die "@_" . _caller() . "\n";
    }
    else {
        die Carp::shortmess(@_) . "\n" if !_is_handler();
    }
}

sub carp {
    if (_is_handler()) {
        warn "@_" . _caller() . "\n";
    }
    else {
        warn Carp::shortmess(@_) . "\n" if !_is_handler();
    }
}

sub _is_handler {
    return 1 if (caller(3))[0] eq 'POE::Kernel';
}

sub _caller {
    package DB;
    my @throw_away = caller(2);
    return " at $DB::args[$file] line $DB::args[$line]";
}

1;
__END__

=head1 NAME

Carp::POE - Carp adapted to POE

=head1 SYNOPSIS

 use Carp::POE;
 use POE;
 
 POE::Session->create(
     package_states => [
         main => [qw( _start test_event )]
     ],
 );

 $poe_kernel->run();

 sub _start {
     $_[KERNEL]->yield(test_event => 'fail');
 }
 
 sub test_event {
     my $arg = $_[ARG0];
     if ($arg ne 'correct') {
         carp "Argument is incorrect!";
     }
 }

=head1 DESCRIPTION

This module provides the same funcions as L<Carp|Carp>, but if they are
called inside a POE event handler, the file/line names are replaced with
POE::Session's C<$_[CALLER_FILE]> and C<$_[CALLER_LINE]>. This is useful
as it will direct you to the code that posted the event instead of
directing you to some subroutine in POE::Session which actually called
the event handler.

Calls to C<carp()> and friends in subroutines that are not POE event
handlers will not be effected, so it's always safe to C<use Carp::POE>
instead of C<Carp>.

=head1 BUGS

Those go here: http://rt.cpan.org/Public/Dist/Display.html?Name=Carp%3A%3APOE

=head1 AUTHOR

Hinrik E<Ouml>rn SigurE<eth>sson <hinrik.sig@gmail.com>

=head1 LICENSE AND COPYRIGHT

Copyright 2008 Hinrik E<Ouml>rn SigurE<eth>sson

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.
