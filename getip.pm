package getip;
use strict;

#my $mac = "38:be:ab:19:4c:d2";
#print GetIPFromMAC($mac); print "\n";

sub GetIPFromMAC
{
    my($mac) = @_;
    $mac = "\L$mac";

    my $debug = 0;

    my @networkInterfaces = Run("ip addr show | awk '/inet.*brd/{print \$NF}'", 1, $debug);
    foreach my $networkInterface (@networkInterfaces)
    {
        my $broadcast=Run("ifconfig | grep --after-context 1 $networkInterface | tail -1 | awk '{print \$6}'",
                          0, $debug);
        # awk print $6 needs improving to find the broadcast address
        Run("ping -b -c 1 $broadcast &>/dev/null", 0, $debug);

        my $ip = Run("ip neighbor | grep -i $mac | awk '{print \$1}'", 0, $debug);
        if($ip ne '')
        {
            if($debug)
            {
                print("$networkInterface: $ip\n");
            }
            return($ip);
        }
    }
}

sub Run
{
    my($exe, $retArray, $debug) = @_;
    chomp $exe;
    if($debug)
    {
        print "### Running: $exe\n";
    }
    if($retArray)
    {
        my @returns = `$exe`;
        foreach my $ret (@returns)
        {
            chomp $ret;
        }
        return(@returns);
    }
    my $ret = `$exe`;
    chomp $ret;
    return($ret);
}

1;
