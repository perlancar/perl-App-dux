package Perinci::CmdLine::dux;
use Moo;
extends 'Perinci::CmdLine';

# VERSION

sub run_subcommand {
    require Tie::Diamond;

    my $self = shift;

    tie my(@diamond), 'Tie::Diamond', {chomp=>1} or die;
    $self->{_args}{in}  = \@diamond;
    $self->{_args}{out} = [];

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
