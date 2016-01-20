#!/usr/bin/perl

#use strict;
use Getopt::Long;
use Log::Log4perl qw(:easy); # We can use INFO(), DEBUG(), WARN() ERROR(), FATAL().
use File::Basename;

# Return types
use constant USAGE_ERROR  => 1;
use constant EXIT_SUCCESS => 0;

# Logger layout pattern
use constant LOG_LAYOUT_PATTERN => "%d %r %p %M-%L %m%n";

# Default log file: ./conf/serviceWatchdog.log
my $logger = "conf/serviceWatchdog.log";
my $verbose = "";
my $help = "";

###############################################################################
#
###### Subroutines >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
###############################################################################

sub Usage
{
	my $ret = shift;
	print STDOUT << 'EOF_USAGE';
Usage:
	--logger|-l <file>	specify the log file path.
	--verbose|-v		debug mode.
	--help|-h		print the help message.

EOF_USAGE

	exit $ret ;
}

sub Init()
{
	# Parse the options
	GetOptions("logger=s"	=> \$logger,
		   "verbose"	=> \$verbose,
		   "help"	=> \$help
		  ) or Usage(USAGE_ERROR);

	Usage(EXIT_SUCCESS) if ($help);
	
	# Initialize log dir
	my $log_dir = dirname($logger);
	umask 0022;
	mkdir $log_dir, 0777 if (! -d $log_dir);

	# Init logger
	if ($verbose)
	{
		Log::Log4perl->easy_init( { level   => $DEBUG,
				    file    => ":utf8>>$logger",
				    layout   => LOG_LAYOUT_PATTERN} );
	} else {
		Log::Log4perl->easy_init( { level   => $INFO,
				    file    => ":utf8>>$logger",
				    layout   => LOG_LAYOUT_PATTERN, } );
	}
}

###############################################################################
#
###### Main >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
###############################################################################
Init();
