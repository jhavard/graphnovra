#!/usr/bin/perl

use XML::Simple;
use Data::Dumper;
use RRDs;

use POSIX qw(strftime);
$now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;


$infoo = `/usr/local/bin/cmcs -xmlstatus`;

my $dat = XMLin($infoo);

$upd = sprintf "N:%s:%s:%s:%s:%s:%s:%s:%s", $dat->{'SIGNAL_STRENGTH_AS_DBM'}, $dat->{'CARRIER_TO_NOISE'}, $dat->{'TOTAL_DVB_PACKETS_ACCEPTED'}, 
        $dat->{'TOTAL_ETHERNET_PACKETS_OUT'}, $dat->{'FREQUENCY_OFFSET'}, $dat->{'TOTAL_UNCORRECTABLE_TS_PACKETS'}, 
        $dat->{'VBER'}, $dat->{'PER'};

$BASE='/export/stats';

$SATF="$BASE/satellite.rrd";

RRDs::update($SATF, $upd);

sub do_graph {
        $file = "$BASE/graphs/" . $_[0];
        $key = $_[1];
        $color = $_[2];
        $comment = $_[3];
        $unit = $_[4];
        RRDs::graph $file, "--start", "end-93600s", "--end", "now", "--width", "600", "-W", "HEATER Labs / WXLAB $now_string", "-E", 
                "DEF:xa=$SATF:${key}:AVERAGE", 
                "DEF:xl=$SATF:${key}:MIN",
                "DEF:xh=$SATF:${key}:MAX",
                "DEF:xn=$SATF:${key}:LAST",
                "LINE1:xa#${color}:${comment}",
                "GPRINT:xn:LAST:Current %5.2lf $unit", "GPRINT:xh:LAST:Max %5.2lf $unit", "GPRINT:xa:LAST:Avg %5.2lf $unit", "GPRINT:xl:LAST:Min %5.2lf $unit";
}       

do_graph "day_cn.png", "sigcn", "FF0000", "dB C/N", "dB";
do_graph "day_dbm.png", "sigdbm", "FF0000", "Signal Strength (dBm)", "dBm";
do_graph "day_dvbacc.png", "dvbaccepted", "00AA00", "DVB Packets Accepted", "pps";
do_graph "day_ethout.png", "ethout", "00AA00", "Ethernet Packets Out","pps";
do_graph "day_freqerr.png", "freqoffset", "0000BB", "Frequency Offset / Error", "Hz";
do_graph "day_uncorr.png", "uncorr", "FF0000", "Uncorrectable Packets", "pkts";
do_graph "day_vber.png", "VBER", "FF9911", "VBER", "VBER";
do_graph "day_per.png", "PER", "99FF11", "PER", "PER";
