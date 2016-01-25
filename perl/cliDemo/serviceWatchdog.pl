#!/usr/bin/perl
################################################################################
# Copyrights (C) 2016 Kankan.com
#
# Monitor kankan running account platform related services. 
# Please specify services in configuration file conf/host.configre.
#
# Package required:
# Log::Log4perl
# Email::Simple
# Email::Sender::Simple
# Email::Sender::Transport::SMTP::TLS
#
# Initial version by liuhongguang@kankan.com
#
# TODO: we might need to make sure every service is starting up with right port.
# 	e.g. mysqld:3306
################################################################################

use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl qw(:easy); # We can use INFO(), DEBUG(), WARN() ERROR(), FATAL().
use File::Basename;
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use Try::Tiny;
use File::Basename;

# Return types
use constant EXIT_SUCCESS 	=> 0;
use constant USAGE_ERROR  	=> 1;
use constant OPEN_FILE_FAILUE	=> 2;

# Logger layout pattern
use constant LOG_LAYOUT_PATTERN => "%d %r %p %M-%L %m%n";

# Use this tag to category emails in Mailbox.
use constant MAIL_TAG => "#ServiceFailureOnServer#";
use constant BINARY_PATH => qw(
	/bin
	/sbin
	/usr/bin
	/usr/sbin
	/usr/local/bin
	/usr/local/sbin
);

# Email rechieve recipients and cc list
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

sub GetCommmandPath($)
{
	my $cmd = shift;
	for my $path (BINARY_PATH)
	{
		return "$path/$cmd" if (-x "$path/$cmd");
	}
	ERROR("Failed to find expected command: [$cmd]");
	return undef;
}

#
# Initialize the command options and logger settings.
#
sub Init()
{
	# Parse the options
	GetOptions("logger=s"	=> \$gLogger,
		   "conf=s"	=> \$gConf,
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

	# the key "kankan" makes no meaning.
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
			DEBUG("Loading entry [$_]");
		}
	}
	close $fd;

	# Append recipients and cc from configuration.
	if (defined $host->{'recipients'})
	{
		$MAIL_RECIPIENTS .= join ',', @{$host->{'recipients'}};
	}
	if (defined $host->{'cclist'})
	{
		$CC_LIST .= join ',', @{$host->{'cclist'}};
	}
	

# Please define $debugConf if need to check the parsing configuration.
#if ($debugConf)
#{
#	for (keys $host)
#	{
#		print "$_: ";
#		print @{$host->{$_}};
#		print "\n";
#	}
#}

}

# two parameters:
#  cmd     - a command or reference to an array of command + arguments
#  timeout - number of seconds to wait (0 = forever)
#
# returns:
#  cmd exit status (-1 if timed out)
#  cmd results (STDERR and STDOUT merged into an array ref)
#
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

#
# Check if specified service is running and listenning to corresponding tcp
# ports.
#
#   $_[0]: $name - service name
#   $_[1]: \%port - tcp ports as hash key
#
#   return: (1, []) - all prots are listened by service.
#   	  (0, \@ports) - specified ports is not listened by service.
#
sub CheckServiceStatusWithTcpPorts
{
	my $name = $_[0];
	my $ports = $_[1];

	# 'netstat' is obsoleted, use 'ss' instead.
	my $cmd = GetCommmandPath("ss");
	my $grep = GetCommmandPath("grep");
	$cmd  = "$cmd -ptln | $grep -w $name"; 
	# Command result of 'ss':
	# State      Recv-Q    Send-Q   Local Address:Port	 Peer 		Address:Port
	# LISTEN	0      1024	*:9001			 *:*        users:(("supervisord",26229,4))
	# Command result of 'netstat':
	# Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name
	# tcp        0      0 10.1.1.92:3306              10.1.1.147:48422            ESTABLISHED 6426/mysqld
	my ($rc, $output) = RunCmd($cmd); 
	if ($rc)
	{
		DEBUG("No port is listened by $name."); 
		return (0, [keys %$ports]);
	}
	my %tmp_ports = %$ports;
	for my $line (@$output)
	{
		# fetch port from output string.
		my $port = (split ':', (split ' ', $line)[3])[1];
		# We don't care how much foreign host is connected to service:port.
		# delete from hash once find that the local port is listened.
		delete $tmp_ports{$port} if (defined $tmp_ports{$port});
	}

	if (scalar keys %tmp_ports)
	{
		my $debug_msg = "ports: [%s] listened by $name are NOT detected.";
		DEBUG(sprintf($debug_msg, join(',', keys%tmp_ports)));
		return (0, [keys %tmp_ports]);
	}
	else
	{
		DEBUG("Ports: " . join(',', keys %$ports) . " listened by $name is detected." );
		return (1, []);
	}	
}

#
# Check if specified services is running or not.
#
#  $_[0]: $name - service name.
#
#  return : 1 - service is running.
#  	    0 - service is stopped.
#
sub CheckServiceStatusWithoutPort
{
	my $name = $_[0];
	# The better command to check a service status should be: service <svc name> status.
	# However since we don't have upstart/systemd scripts deployed for our binaries,
	# use the "pidof" to check service running status here.
	my $cmd = GetCommmandPath("pidof");
	$cmd = "$cmd $name"; 
	my ($rc, $output) = RunCmd($cmd); 
	DEBUG(@$output) if (@$output); 
	if ($rc) 
	{ 
		DEBUG("$name is not running."); 
		return 0;
	} 
	return 1;

}

#
# Check if specified services are running or not.
# Take care this scenarios:
# 1. Service has n daemon entries running on server:
#    e.g. mysqld:3306, mysqld:3307 and mysqld3309
#
# Workaround: only count the number of daemons running on server.
#     Will not check if the port is valid.
#
# $_[0]:  array   -  service name to be check in array.
#
# return: $result - an array reference with stopped services.
#
sub CheckServicesStatus($)
{
	# Raw data from configuration file.
	my $services = $_[0];
	my @result;
	my %services;
	# Raw data format: <name:port> per line.
	for my $service (@$services)
	{
		#my ($name, $port) = ($service =~ m/([^:]*):([^:]*)/)[0, 1];
		my ($name, $port);
		if ($service =~ m/([^:]*):([^:]*)/)
		{
			$name = $1, $port = $2;
			# Skip null name.
			next unless($name);
			DEBUG("Get service $name:$port");
			# No need the full path
			$services{basename($name)}{$port} = 1;
		}
		elsif ($service =~ m/([^:]*)/)
		{
			$name = $1;
			# Skip null name.
			next unless($name);
			DEBUG("Get service $name:N/A");
			$services{basename($name)} = 1;
		}
	}

	for my $service (keys %services)
	{
		my ($rc, $output);
		if (ref($services{$service}) eq "HASH")
		{
			($rc, $output) = CheckServiceStatusWithTcpPorts($service, $services{$service});
			next if ($rc);
			my $missed_ports = join ',', @$output;
			push @result, "$service:$missed_ports";
		}
		# Note that if we define my $var = "value"; then ref(\$var) is 'SCALAR'
		elsif (ref(\$services{$service}) eq "SCALAR")
		{
			$rc = CheckServiceStatusWithoutPort($service);
			next if ($rc);
			push @result, $service;
		}
	
	}
	return \@result;
}

# Send an email with the stopped services to administrators.
#
# $_[0]:  $failed_services - all stopped services
#
sub SendEMail($)
{
	my $failed_services = $_[0];
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
Services:
	$failed_services


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

my $stopped_services = CheckServicesStatus(\@{$host->{service}});
if (@$stopped_services > 0)
{
	my $stop_svcs = join "\n\t", @$stopped_services;
	my $stop_svcs_msg = join ", ", @$stopped_services;
	my $msg = "Services [$stop_svcs_msg] are not running.";
	ERROR($msg);
	SendEMail($stop_svcs);
}
else
{
	INFO("Congratulations! All sppcified servies are running well.");
}

exit 0;
