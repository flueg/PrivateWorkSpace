#
#
#
#/bin/sh /usr/share/centrifydc/perl/run

use lib '/usr/share/centrifydc/perl';
use CentrifyDC::GP::General qw(RunCommand ReadFile);

my $MARKER = "__SSH_REMOTE_COMMAND_MARDER__";

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
sub IsLocalDirEmpty($)
{
    my $dir = $_[0];
    return 0 if (! -d $dir);
    # Command to test if directory is empty.
    my $cmd_get_dir_fnode = "ssh -t localhost \"echo $MARKER; ls -A %s; echo $MARKER\"";
    my $command = sprintf($cmd_get_dir_fnode, $dir);
    my ($rc, $command_output) = RunCommand($command);
    if ($rc)
    {
         USER_ERROR("Undefined error");
         return undef;
    }
    print("$command_output\n");
    my $sout = ParseResultWithMarker($command_output);
    chomp $sout;
    print("sort result:\n[$sout]\n");
    return 0 if ($sout);
    return 1;
}
my $dir = $ARGV[0];

#IsLocalDirEmpty($dir);

if (IsLocalDirEmpty($dir))
{
    print ("$dir is an empty directory.\n");
}
else
{
    print ("$dir is not empty.\n");
}
