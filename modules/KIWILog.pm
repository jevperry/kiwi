#================
# FILE          : KIWILog.pm
#----------------
# PROJECT       : OpenSUSE Build-Service
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH, Germany
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : This module is used for logging purpose
#               : to ensure a single point for all log
#               : messages
#               :
# STATUS        : Development
#----------------
package KIWILog;
#==========================================
# Modules
#------------------------------------------
use strict;
use Carp qw (cluck);

#==========================================
# Private
#------------------------------------------
my @showLevel = (0,1,2,3,4,5);
my $channel   = \*STDOUT;
my $logfile;

#==========================================
# Constructor
#------------------------------------------
sub new {
	# ...
	# Construct a new KIWILog object. The log object
	# is used to print out info, error and warning
	# messages
	# ---
	my $this  = {};
	my $class = shift;
	bless $this,$class;
	return $this;
}

#==========================================
# getColumns
#------------------------------------------
sub getColumns {
	# ...
	# get the terminal number of columns because we want
	# to put the status text at the end of the line
	# ---
	my $this = shift;
	my $size = qx (stty size); chomp ($size);
	my @size = split (/ +/,$size);
	return pop @size;
}

#==========================================
# doStat
#------------------------------------------
sub doStat {
	# ...
	# Initialize cursor position counting from the
	# end of the line
	# ---
	my $cols = getColumns();
	printf ("\015\033[%sC\033[10D",$cols);
}

#==========================================
# doNorm
#------------------------------------------
sub doNorm {
	# ...
	# Reset cursor position to standard value
	# ---
    print "\033[m\017";
}

#==========================================
# done
#------------------------------------------
sub done {
	# ...
	# This is the green "done" flag
	# ---
    doStat();
    print "\033[1;32mdone\n";
    doNorm();
}

#==========================================
# failed
#------------------------------------------
sub failed {
	# ...
	# This is the red "failed" flag
	# ---
    doStat();
    print "\033[1;31mfailed\n";
    doNorm();
}

#==========================================
# log
#------------------------------------------
sub printLog {
	# ...
	# print log message to an optional given output channel
	# reference. The output channel can be one of the standard
	# channels or a previosly opened file
	# ---
	my $this = shift;
	my $lglevel = $_[0];
	my $logdata = $_[1];

	my $date;
	if (! defined $channel) {
		$channel = \*STDOUT;
	}
	if ($lglevel !~ /^\d$/) {
		$logdata = $lglevel;
		$lglevel = 1;
	}
	$date = qx ( LANG=POSIX /bin/date "+%h-%d %H:%M");
	$date =~ s/\n$//;
	$date .= " <$lglevel> : ";

	foreach my $level (@showLevel) {
	if ($level == $lglevel) {
		open ( OLDERR, ">&STDERR" );
		open ( OLDSTD, ">&STDOUT" );
		open ( STDERR,">&$$channel" );
		open ( STDOUT,">&$$channel" );
		if (($lglevel == 1) || ($lglevel == 3)) {
			print $date,$logdata;
		} elsif ($lglevel == 5) {
			print $logdata;
		} else {
			cluck $date,$logdata;
		}
		close ( STDERR ); open ( STDERR, ">&OLDERR" );
		close ( STDOUT ); open ( STDOUT, ">&OLDSTD" );
		return $lglevel;
	}
	}
}

#==========================================
# info
#------------------------------------------
sub info {
	# ...
	# print an info log message to channel <1>
	# ---
	my $this = shift;
	my $data = shift;
	printLog ( $this,1,$data );
}

#==========================================
# error
#------------------------------------------
sub error {
	# ...
	# print an error log message to channel <3>
	# ---
	my $this = shift;
	my $data = shift;
	printLog ( $this,3,$data );
}

#==========================================
# warning
#------------------------------------------
sub warning {
	# ...
	# print a warning log message to channel <2>
	# ---
	my $this = shift;
	my $data = shift;
	printLog ( $this,2,$data );
}

#==========================================
# message
#------------------------------------------
sub note {
	# ...
	# print a raw log message to channel <5>.
	# This is a message without date and time
	# information
	# ---
	my $this = shift;
	my $data = shift;
	printLog ( $this,5,$data );
}

#==========================================
# setLogFile
#------------------------------------------
sub setLogFile {
	# ...
	# set a log file name for logging. Each call of
	# a log() method will write its data to this file
	# ---
	my $this = shift;
	my $file = $_[0];
	if (! (open FD,">$file")) {
		warning ( $this,"Couldn't open log channel: $!\n" );
		return 0;
	}
	$logfile = \*FD;
	$channel = \*FD;
	return 1;
}

1;
