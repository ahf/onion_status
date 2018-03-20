use strict;
use warnings;

use POSIX qw(strftime);

use Irssi;

our $VERSION = "1.0";
our %IRSSI = (
    authors     => 'Alexander Færøy',
    contact     => 'ahf@torproject.org',
    name        => 'onion_status.pl',
    license     => 'BSD-2-Clause',
    description => 'Helper script for daily status reporting in #tor-dev.',
);

sub handle_status_message {
    my ($server, $target, $nickname, $message) = @_;

    my $channel = Irssi::settings_get_str('onion_status_channel');
    my $members_only = Irssi::settings_get_bool('onion_status_members_only');
    my @members = split(' ', Irssi::settings_get_str('onion_status_members'));

    # Check if we are in the right channel.
    if ("$server->{'tag'}/$target" ne $channel) {
        return;
    }

    # Check if we should only allow members to submit status updates.
    if ($members_only) {
        if (! grep(/^$nickname$/, @members)) {
            return;
        }
    }

    # Print to the window, if it exists.
    my $window_name = Irssi::settings_get_str('onion_status_window');
    my $highlight = Irssi::settings_get_bool('onion_status_highlight');
    my $window = Irssi::window_find_name($window_name);

    if ($window) {
        my $level = MSGLEVEL_CRAP;

        # We are not interested in highlighting our own messages.
        if ($highlight && $server->{'nick'} ne $nickname) {
            $level = $level | MSGLEVEL_HILIGHT;
        }

        $window->printformat($level, 'onion_status_message', $nickname, $message);
    }

    # Log to file.
    my $log_file = Irssi::settings_get_str('onion_status_log_file');
    my $log_enabled = Irssi::settings_get_bool('onion_status_log');

    if ($log_enabled) {
        my $timestamp_format = Irssi::settings_get_str('onion_status_log_timestamp');
        my $timestamp = strftime($timestamp_format, localtime);

        if (open(LOG, ">>", glob($log_file))) {
            print LOG "$timestamp $target $nickname status: $message\n";
            close LOG;
        }
    }
}

sub signal_action {
    my ($server, $message, $nickname, $address, $target) = @_;

    if ($message =~ m/^status[:]? (.*)$/) {
        handle_status_message($server, $target, $nickname, $1);
    }
}

sub signal_own_action {
    my ($server, $message, $target) = @_;

    if ($message =~ m/^status[:]? (.*)$/) {
        handle_status_message($server, $target, $server->{'nick'}, $1);
    }
}

Irssi::settings_add_str('onion_status', 'onion_status_window', 'tor-dev-status');
Irssi::settings_add_str('onion_status', 'onion_status_channel', 'OFTC/#tor-dev');
Irssi::settings_add_str('onion_status', 'onion_status_members', 'ahf asn catalyst dgoulet isabela isis nickm teor teor4');
Irssi::settings_add_str('onion_status', 'onion_status_log_file', '~/.irssi/status.log');
Irssi::settings_add_str('onion_status', 'onion_status_log_timestamp', '%Y/%m/%d %H:%M:%S');
Irssi::settings_add_bool('onion_status', 'onion_status_log', 1);
Irssi::settings_add_bool('onion_status', 'onion_status_members_only', 1);
Irssi::settings_add_bool('onion_status', 'onion_status_highlight', 1);

Irssi::theme_register([
    'onion_status_message', '%wstatus update from %n%W$0%n%K:%n $1',
    'onion_status_loaded', '%G>>%n Loaded $0 version $1.',
    'onion_status_create_window', '%G>>%n Please create status window using: \'/window new hidden\', then \'/window name $0\'.',
]);

Irssi::signal_add('message irc action', 'signal_action');
Irssi::signal_add('message irc own_action', 'signal_own_action');

Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'onion_status_loaded', $IRSSI{name}, $VERSION);

our $window_name = Irssi::settings_get_str('onion_status_window');
our $window = Irssi::window_find_name($window_name);

if (! $window) {
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'onion_status_create_window', $window_name)
}
