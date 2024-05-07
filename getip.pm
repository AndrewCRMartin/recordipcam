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
        my $ip = Run("ip neighbor | grep -i $mac | awk '{print \$1}' | tail -1", 0, $debug);

        # 08.04.25 Try pinging each address in turn if the ping of the broadcast
        #          address didn't work
        if($ip eq '')
        {
            for(my $i=1; $i<255; $i++)
            {
                my $address = $broadcast;
                $address =~ s/\.\d+$/\.$i/;
                `ping -c 1 $address`;
            }
            $ip = Run("ip neighbor | grep -i $mac | awk '{print \$1}' | tail -1", 0, $debug);
        }
        
        if($ip ne '')
        {
            if($debug)
            {
                print("$networkInterface: $ip\n");
            }
            chomp $ip;
            return($ip);
        }
    }
    return('');
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
