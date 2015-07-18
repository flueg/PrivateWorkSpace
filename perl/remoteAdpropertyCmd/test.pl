#!/bin/sh /usr/share/centrifydc/perl/run

use lib '/usr/share/centrifydc/perl';
use CentrifyDC::GP::General qw(:debug RunCommand ReadFile);

my $MARKER = "__SSH_REMOTE_COMMAND_MARDER__";

sub SaveToFile($)
{
    my $content = $_[0];
    open FD, '>', "output.save";
    printf(FD $content);
    close FD;
}

sub ParseResultWithMarker($)
{
    my $output = $_[0];
    my $result = "";
    my $flag = 0;

    foreach (split("\n", $output))
    {
        s/\r//g;
        if (m/^$MARKER$/)
        {
            $flag++;
            next;
        }
        next if ($flag != 1);
        $result .= "$_\n";
    }

    return $result;
}


# Test if path is an empty dir.
# 
#    $_[0]:  $path, the absolute path.
# 
#    return - 1: path is an empty dir.
#           - 0: path is not dir or not empty.
#           - undef: error.
# 
sub RunSshCommand($$)
{
    my $prop = $_[0];
    my $host = $_[1];
    # Command to test if directory is empty.
    my $command = "ssh -t $host \"echo $MARKER; /usr/share/centrifydc/bin/adproperty -g $prop; echo $MARKER\"";
    my ($rc, $command_output) = RunCommand($command);
    if ($rc)
    {
         ERROR_OUT("Undefined error");
         return undef;
    }
    print("command output:\n$command_output\n");
    SaveToFile($command_output);

    my $soutput = ParseResultWithMarker("$command_output");
    chomp $soutput;
    print("sort resout: [$soutput]\n");
    return 1 if ($command_output == 0);
    return 0;
}
my $prop = $ARGV[0];
my $host = $ARGV[1];
$prop = "adclient.krb5.service.principals" if (!$prop);
$host = "localhost" if (!$host);

RunSshCommand($prop, $host);
