#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl qw(:easy); # We can use INFO(), DEBUG(), WARN() ERROR(), FATAL().
use File::Basename;
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use Try::Tiny;

# Return types
use constant EXIT_SUCCESS 	=> 0;
use constant USAGE_ERROR  	=> 1;
use constant OPEN_FILE_FAILUE	=> 2;

# Logger layout pattern
use constant LOG_LAYOUT_PATTERN => "%d %r %p %M-%L %m%n";

# Email rechieve recipients and cc list
use constant MAIL_TAG => "#ServiceFailureOnServer#";
my $MAIL_RECIPIENTS = 'liuhongguang@kankan.com,';
my $CC_LIST = 'liuhongguang@kankan.com,';

# Default log file: ./conf/serviceWatchdog.log
my $gLogger = "log/serviceWatchdog.log";
my $gConf = "conf/host.configure";
my $debugConf;
my $gVerbose = "";
my $help = "";

my $host = ();

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
	--conf|-c <file>	specify the host configuration file path.
	--verbose|-v		debug mode.
	--help|-h		print the help message.

EOF_USAGE

	exit $ret ;
}

#
# Initialize the command options and logger settings.
#
sub Init()
{
	# Parse the options
	GetOptions("logger=s"	=> \$gLogger,
		   "verbose"	=> \$gVerbose,
		   "help"	=> \$help
		  ) or Usage(USAGE_ERROR);

	Usage(EXIT_SUCCESS) if ($help);
	
	# Initialize log dir
	my $log_dir = dirname($gLogger);
	umask 0022;
	mkdir $log_dir, 0777 if (! -d $log_dir);

	# Init logger
	if ($gVerbose)
	{
		Log::Log4perl->easy_init( { level   => $DEBUG,
				    file    => ":utf8>>$gLogger",
				    layout   => LOG_LAYOUT_PATTERN,
					} );
	}
	else
	{
		Log::Log4perl->easy_init( { level   => $INFO,
				    file    => ":utf8>>$gLogger",
				    layout   => LOG_LAYOUT_PATTERN,
					 } );
	}
}

# Load the host configuration file to get the services.
sub LoadConfiguration
{
	# Open for read.
	my $rc = open my $fd, '<', $gConf;
	if (!$rc)
	{
		ERROR("Fail to read file [$gConf]: $!");
		return OPEN_FILE_FAILUE;
	}

	my $key = "kankan";
	while (<$fd>)
	{
		# Skips comment and empty lines.
		next if (m/^#|^\s*$/);
		s/^\s*//;
		s/\s*$//;

		if (m/^\[(.*)\]$/)
		{
			$key = $1;
			DEBUG("Loading configuration section [$key]");
		}
		else
		{
			push @{$host->{$key}}, $_;
		}
	}
	close $fd;

	if (defined $host->{'recipients'})
	{
		$MAIL_RECIPIENTS .= join ',', @{$host->{'recipients'}};
	}
	if (defined $host->{'cclist'})
	{
		$CC_LIST .= join ',', @{$host->{'cclist'}};
	}
	

# Please define $debugConf if need to check the parsing configuration.
if ($debugConf)
{
	for (keys $host)
	{
		print "$_: ";
		print @{$host->{$_}};
		print "\n";
	}
}

}

# two parameters:
#  cmd     - a command or reference to an array of command + arguments
#  timeout - number of seconds to wait (0 = forever)

# returns:
#  cmd exit status (-1 if timed out)
#  cmd results (STDERR and STDOUT merged into an array ref)

sub RunCmd
{
  my $cmd = shift || return(0, []);
  my $timeout = shift || 0;

  # opening a pipe creates a forked process    
  my $pid = open(my $pipe, '-|');
  return(-1, "Can't fork: $!") unless defined $pid;

  if ($pid) {
    # this code is running in the parent process

    my @result = ();

    if ($timeout) {
      my $failed = 1;
      eval {
        # set a signal to die if the timeout is reached
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm $timeout;
        @result = <$pipe>;
        alarm 0;
        $failed = 0;
      };
      return(-1, ['command timeout', @result]) if $failed;
    }
    else {
      @result = <$pipe>;
    }
    close($pipe);

    # return exit status, command output
    return ($? >> 8), \@result;
  }

  # this code is running in the forked child process

  { # skip warnings in this block
    no warnings;

    # redirect STDERR to STDOUT
    open(STDERR, '>&STDOUT');

    # exec transfers control of the process
    # to the command
    ref($cmd) eq 'ARRAY' ? exec(@$cmd) : exec($cmd);
  }

  # this code will not execute unless exec fails!
  print "Can't exec @$cmd: $!";
  exit 1;
}


sub CheckServiceStatus($)
{
	my $services = $_[0];
	my @result;
	for my $service (@$services)
	{
		my $cmd = "pidof $service";
		my ($rc, $output) = RunCmd($cmd);
		DEBUG(@$output) if (@$output);
		if ($rc)
		{
			DEBUG("$service is not running.");
			push @result, $service;
		}
	}
	return \@result;
}

sub SendEMail($)
{
	my $body = $_[0];
	my $uname = `whoami`;
	chomp $uname;
	my $host_name = `hostname`;
	chomp $host_name;
	my $mail_sender = "$uname\@$host_name";
	DEBUG("From: $mail_sender");
	my $subject = MAIL_TAG . "Services are stopped unexpectly!";
	my $new_email = Email::Simple->create(
		header => [
			From	=> $mail_sender,
			To	=> $MAIL_RECIPIENTS,
			Cc	=> $CC_LIST,
			Subject => $subject,
		],
		body 		 => <<MAIL_BODY,
HostName: @{$host->{'hostname'}}
Host: @{$host->{'host'}}
Services: $body


Note: If you don't want to rechieve this email again, please contact Flueg (liuhongguang\@kankan.com) to unsubscribe.

Thanks very much.
Flueg

MAIL_BODY
	);

	# Send the mail
	try { 
		DEBUG("Sending mail ...");
		sendmail($new_email);
	} catch {
		ERROR("Fail to send email.");
	};

}

###############################################################################
#
###### Main >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
###############################################################################
Init();
INFO("Start to check if specified services is running ...");

LoadConfiguration();

my $stopped_services = CheckServiceStatus(\@{$host->{service}});
if (@$stopped_services > 0)
{
	my $stop_svcs = join ", ", @$stopped_services;
	my $msg = "Services [$stop_svcs] are not running.";
	ERROR($msg);
	SendEMail($stop_svcs);
}
else
{
	INFO("Congratulations! All sppcified servies are running well.");
}

exit 0;
