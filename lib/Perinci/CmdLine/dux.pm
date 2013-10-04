package Perinci::CmdLine::dux;
use 5.010;
use Moo;
extends 'Perinci::CmdLine';

# VERSION

# we don't have our own color theme class
has color_theme_class_prefix => (
    is => 'rw',
    default => sub { 'Perinci::CmdLine::ColorTheme' },
);

sub run_subcommand {
    my $self = shift;

    # set `in` argument for the dux function
    my $chomp = $self->{_meta}{"x.dux.strip_newlines"} // 1;
    require Tie::Diamond;
    tie my(@diamond), 'Tie::Diamond', {chomp=>$chomp} or die;
    $self->{_args}{in}  = \@diamond;

    # set `out` argument for the dux function
    my $streamo = $self->{_meta}{"x.dux.is_stream_output"};
    my $fmt = $self->format;
    if (!defined($streamo)) {
        # turn on streaming if format is simple text
        my $iactive;
        if (-t STDOUT) {
            $iactive = 1;
        } elsif ($ENV{INTERACTIVE}) {
            $iactive = 1;
        } elsif (defined($ENV{INTERACTIVE}) && !$ENV{INTERACTIVE}) {
            $iactive = 0;
        }
        $streamo = 1 if $fmt eq 'text-simple' || $fmt eq 'text' && !$iactive;
    }
    #say "fmt=$fmt, streamo=$streamo";
    if ($streamo) {
        die "Can't format stream as $fmt, please use --format text-simple\n"
            unless $self->format =~ /^text/;
        $self->{_is_stream_output} = 1;
        require Tie::Simple;
        my @out;
        tie @out, "Tie::Simple", undef,
            PUSH => sub {
                my $data = shift;
                for (@_) {
                    print $self->format_row($_);
                }
            };
        $self->{_args}{out} = \@out;
    } else {
        $self->{_args}{out} = [];
    }

    $self->{_args}{-dux_cli} = 1;

    $self->SUPER::run_subcommand(@_);
}

sub format_result {
    my $self = shift;

    if ($self->{_is_stream_output}) {
        $self->{_fres} = "";
        return;
    }

    if ($self->{_res} && $self->{_res}[0] == 200) {
        # insert out to result, so it can be displayed
        $self->{_res}[2] = $self->{_args}{out};
    }
    $self->SUPER::format_result(@_);
}

1;
# ABSTRACT: Perinci::CmdLine subclass for dux cli

=head1 DESCRIPTION

This subclass sets C<in> and C<out> arguments for the dux function, and displays
the resulting <out> array.

It also add a special flag function argument C<< -dux_cli => 1 >> so the
function is aware it is being run through the dux CLI application.


=head1 SEE ALSO

L<Perinci::CmdLine>

=cut
