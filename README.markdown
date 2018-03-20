Onion Status
============

This repository contains an Irssi script to help with the daily status updates
in `#tor-dev` on OFTC from the Tor project's network team members.

The script supports the following features:

- Log daily status messages to a log file.
- Log daily status messages to a status window inside Irssi.
- Allow the user to enable a filter such that only messages from user approved
  members are logged.

## Usage

Download the `onion_status.pl` script and store it as
`~/.irssi/scripts/onion_status.pl`. Create a symlink from
`~/.irssi/scripts/autorun/onion_status.pl` to
`~/.irssi/scripts/onion_status.pl` and load the script inside Irssi using:

    /SCRIPT LOAD onion_status.pl

Check if the default settings seems reasonable using:

    /SET onion_status

### Create status window inside Irssi

If you want to use the status window inside of Irssi create a new empty window
using:

    /WINDOW NEW HIDDEN
    /WINDOW NAME tor-dev-status

## Settings

- `onion_status_window` (Default: `tor-dev-status`): This setting defines the
  name of the window inside of Irssi where status messages are logged to.

- `onion_status_channel` (Default: `OFTC/#tor-dev`): This setting defines the
  name of the network and the nel that we are interested in tracking status
  updates in.

- `onion_status_highlight` (Default: `ON`): Do we want the window to get
  highlighted when a new status message arrives?

- `onion_status_members_only` (Default: `ON`): Do we only want to log status
  updates from nicknames in `onion_status_members`?

- `onion_status_members` (Default: list of network team members): This setting
  defines a list of members to log status updates from. The string contains a
  space delimited list of nicknames.

- `onion_status_log` (Default `ON`): Do we want to log status messages to a
  file?

- `onion_status_log_file` (Default: `~/.irssi/status.log`): The file where we
  save status updates in.

- `onion_status_log_timestamp` (Default: `%Y/%m/%d %H:%M:%S`): `strftime(3)`
  log timestamp format.
