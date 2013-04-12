package Perinci::CmdLine::dux;
use Moo;
extends 'Perinci::CmdLine';

# VERSION

sub run_subcommand {
    require Tie::Diamond;

    my $self = shift;

    # set `in` and `out` arguments for the dux function
    my $chomp = $self->{_meta}{"x.dux.strip_newlines"} // 1;
    tie my(@diamond), 'Tie::Diamond', {chomp=>$chomp} or die;
    $self->{_args}{in}  = \@diamond;
    $self->{_args}{out} = [];

    # set default output format from metadata, if specified and user has not
    # specified --format
    my $mfmt = $self->{_meta}{"x.dux.default_format"};
    $self->format($mfmt) unless
        grep {/^--format/} @{ $self->{_orig_argv} }; # not a proper way, but will do for now

    $self->SUPER::run_subcommand(@_);
}

sub format_and_display_result {
    my $self = shift;
    if ($self->{_res} && $self->{_res}[0] == 200) {
        # insert out to result, so it can be displayed
        $self->{_res}[2] = $self->{_args}{out};
    }
    $self->SUPER::format_and_display_result(@_);
}

1;
# ABSTRACT: Perinci::CmdLine subclass for dux cli

=head1 DESCRIPTION

This subclass sets `in` and `out` arguments for the dux function, and displays
the resulting `out` array.


=head1 SEE ALSO

L<Perinci::CmdLine>

=cut

