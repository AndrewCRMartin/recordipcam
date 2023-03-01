#!/usr/bin/perl

use lib '.';
use config;
use utils;

my %config = config::ReadConfig('test.cfg');

# If the camera's IP address is not up, then exit
if(!CameraUp($config{'ip'}))
{
    utils::mydie("Camera at $config{'ip'} is not responding");
}

if(!utils::MakeDir($config{'outputDir'}))
{
    utils::mydie("Cannot create output directory ($config{'outputDir'})");
}

# Fork the ManageData process
my $pidManageData = fork;
die "failed to fork ManageData: $!" unless defined $pidManageData;
if ($pidManageData == 0) {
  ManageData(\%config);
  exit;
}

# Fork the DataCheck process
my $pidDataCheck = fork;
die "failed to fork DataCheck: $!" unless defined $pidDataCheck;
if ($pidDataCheck == 0) {
  DataCheck(\%config);
  exit;
}

# Fork the RecordVideo process
my $pidRecordVideo = fork;
die "failed to fork RecordVideo: $!" unless defined $pidRecordVideo;
if ($pidRecordVideo == 0) {
  RecordVideo(\%config);
  exit;
}

#SetSignalHandler($pidManageData, $pidDataCheck, $pidRecordVideo);

waitpid $pidManageData,  0;
waitpid $pidDataCheck,   0;
waitpid $pidRecordVideo, 0;


sub SetSignalHandler
{
    my (@pids) = @_;
    $SIG{HUP}  = \&SignalHandler(@pids);
    $SIG{INT}  = \&SignalHandler(@pids);
    $SIG{QUIT} = \&SignalHandler(@pids);
    $SIG{ABRT} = \&SignalHandler(@pids);
    $SIG{KILL} = \&SignalHandler(@pids);
    $SIG{TERM} = \&SignalHandler(@pids);
    $SIG{USR1} = \&SignalHandler(@pids);
    $SIG{USR2} = \&SignalHandler(@pids);
}

sub SignalHandler
{
    my (@pids) = @_;
    foreach my $pid (@pids)
    {
        if($pid ne '')
        {
            print STDERR "Killing $pid\n";
            `kill -9 $pid`;
        }
    }
}

#########################################################################
sub ManageData
{
    my($hConfig) = @_;
    $0 = 'recordip-ManageData';
    print "Started data management process\n";
    while(1)
    {
        last if(!DeleteOldFiles($hConfig));
        sleep(24*60*60);
    }
}

sub DeleteOldFiles
{
    my($hConfig) = @_;
    my $dir  = $$hConfig{'outputDir'};
    my $keep = $$hConfig{'keepRecordings'} * 24 * 60 * 60;

    if(opendir(my $dfp, $dir))
    {
        my @files = grep(!/^\./, readdir($dfp));
        foreach my $file (@files)
        {
            if(($file =~ /\.mkv$/) && ((time - (stat($file))[9] ) > $keep))
            {
                unlink($file);
            }
        }
        closedir($dfp);
    }
    else
    {
        printf STDERR "Error: Can't read directory ($dir)\n";
        return(0);
    }
    return(1);
}

#########################################################################
sub DataCheck
{
    my($hConfig) = @_;
    $0 = 'recordip-DataCheck';
    print "Started data checking process\n";
    while(1)
    {
        sleep(60);
        if(!CheckData($hConfig))
        {
            KillFFMpeg($hConfig);
        }
    }
}

sub KillFFMpeg
{
    my($hConfig) = @_;
    my $result = `ps auxwww | grep ffmpeg | grep $$hConfig{'ip'} | awk '{print $2}'`;
    print STDERR "Killing FFMPeg\n";
    `kill -9 $result`;
}

sub CheckData
{
    my($hConfig) = @_;
    return(1);
}

#########################################################################
sub RecordVideo
{
    my($hConfig) = @_;
    $0 = 'recordip-Record';
    print "Started recording video\n";
    my $exe = "xxxxxxxxx";

    while(1)
    {
        my $givenError = 0;

        #        system($exe);
        sleep(20);

        if(!CameraUp($$hConfig{'ip'}))
        {
            if(!$givenError)
            {
                print STDERR "ffmpeg died as camera is down. Sleeping...\n";
                $givenError = 1;
            }
            sleep 60;
        }
    }
}

#########################################################################
sub CameraUp
{
    my($ip) = @_;

    return(1);
    
    my $nPing = 5;
    my $exe = "ping -c $nPing $ip 2>/dev/null | grep bytes | grep -v PING";
    my $result = `$exe`;
    my @lines  = split(/\n/, $result);
    return(1) if(scalar(@lines) == $nPing);
    return(0);
}
