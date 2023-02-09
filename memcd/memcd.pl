#! /usr/bin/env perl
# ==================================================
# Filename: memcd.pl
# Date    : 2023-01-05
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

use strict;
use warnings;

use FindBin qw($RealBin);
use lib "$RealBin/objects";

use Cwd qw(abs_path);
use Getopt::Std;

use Term::ANSIColor;

require "DirDB.pl";

# ==================================================
# Variables

# Database size limit (lines)
my $DBlimit = 20;

# Set this variable to 0/1 for normal/debug mode
my $debug = 0;

# The number of successive times this path has not been chose
my $forgotten_times = 5;

# Be at least a number of call time to be in the forgotten list
my $forgotten_thres = 3;

# Directory database object
my $dir_db;

# Command line options - default value, with syntax:
# option => ["no option", "option but value"]
my %opt_def = ( p => ["./", "./"], # path, can be defined with a value
                l => [0, 1],       # list
                a => [0, 1],       # all
                g => [0, 1],       # long
                c => [0, 6],       # clue, can be defined with a value
                s => [0, 1],       # save
                b => [0, 1],       # bias
                r => [0, 1],       # rmv
                h => [0, 1],       # help
                m => [0, 1],       # machine
              );

# Command line options - real value
my $opt = ();

# All path available in the database
my $path_arr = ();

# Directory database file
my $db_file = "$RealBin/memcd.db";

# ==================================================
# Processing
&getCommandLineArgument();
&getHelp();
&loadDatabase();
&processPath();
&processRemove();
&processSave();
&processClue();
#&processList(); # Currently removed because of no color bug
&saveDatabase();
exit(0);

# ==================================================
# Subroutines
# *** getCommandLineArgument
#     ___ Get all the command line options and save
#         to $opt
#     ___ Check if new directory is valid, exit if
#         not
# *** loadDatabase
#     ___ Load the database file and save to object
#         $db_dir
# *** processPath
#     ___ Change current directory to the absolute
#         path of the new directory
# *** processSave
#     ___ Save this new directory into the database
# *** processRemove
#     ___ Remove this directory from the database
# *** processClue
#     ___ Gives the clue of the most frequent
#         accessed directory
# *** processList
#     ___ List files based on command line options
# *** processDB
#     ____ Sorting and cut down the database if the
#         number of paths exceeds
# *** checkForFatalOptionErrors
#     ___ Make sure no unknown arguments passed
#         through GetOptions
# *** saveDatabase
#     ___ Save the database from object $db_dir to
#         the database file
# *** getHelp
#     ___ Print a small user guide then exit
# ==================================================
sub getCommandLineArgument {
	my @option_arr = ('a', 'b', 'c', 'g', 'h', 'l', 'p' ,'r', 's', 'm');
	my @arg_arr = ('c', 'p');

	foreach( @option_arr ) {
		if( "@ARGV" =~ /-[a-zA-Z]*$_[a-zA-Z]*/ ) {
			$opt->{$_} = $opt_def{$_}->[1];
		} else {
			$opt->{$_} = $opt_def{$_}->[0];
		}
	}

	foreach( @arg_arr ) {
		if( "@ARGV" =~ /$_ ([^- ]+)/ ) {
			$opt->{$_} = $1;
		}
	}

	$opt->{list} = delete $opt->{l};
	$opt->{all}  = delete $opt->{a};
	$opt->{long} = delete $opt->{g};
	$opt->{clue} = delete $opt->{c};
	$opt->{save} = delete $opt->{s};
	$opt->{path} = delete $opt->{p};
	$opt->{rmv}  = delete $opt->{r};
	$opt->{help} = delete $opt->{h};
	$opt->{bias} = delete $opt->{b};
	$opt->{mach} = delete $opt->{m};

	# foreach( keys %$opt) {
	# 	print $_, ": ", $opt->{$_}, "\n";
	# }
	# print "============================================\n";

	# &checkForFatalOptionErrors();

}

sub loadDatabase {
	$dir_db = DirDB->new( DBlimit => $DBlimit,
												debug   => $debug,
                        forgotten_times => $forgotten_times,
                        forgotten_thres => $forgotten_thres
												);
	$dir_db->loadDB($db_file);
}

sub processPath {
  if( $opt->{path} =~ /__(\d)__/ ) {
	  $path_arr = $dir_db->sortDB();
    $opt->{path} = @$path_arr[$1];
  }
  if( $opt->{mach} ) {
    print $opt->{path};
    exit 1;
  }
	$opt->{path} = abs_path($opt->{path});
	unless( $opt->{path} =~ /\/\$/ ) { $opt->{path} .= "/"; }

	unless( -e $opt->{path} or $opt->{rmv} ) {
    print color('bold red'), "[ERROR] ", color('reset'), "Can't find $opt->{path}\n";
		exit(1);
	}

	unless( chdir $opt->{path} or $opt->{rmv} ) {
    print color('bold red'), "[ERROR] ", color('reset'), "Can't change directory to $opt->{path}\n";
		exit(1);
	}
}

sub processSave {
	if( $opt->{save} ) {
		if( $opt->{bias} ) {
			$dir_db->addPathToDB( $opt->{path}, ("preferred") );
		} else {
			$dir_db->addPathToDB( $opt->{path}, ("-") );
		}
	}
	&processDB();
}

sub processRemove {
	if( $opt->{rmv} ) {
		$dir_db->removePath( $opt->{path} );
	}
}

sub processClue {
	if( $opt->{clue} > 0 ) {
		my $header = "\n";
		my $i = 0;
		$opt->{clue} = @$path_arr if( @$path_arr < $opt->{clue} );
		$i = 6 - $opt->{clue} if( $opt->{clue} < 6 );
    my $start = $i - 1;
		print "Your most frequently visited directory:";
		foreach( @$path_arr ) {
			if(    $i == 0 ) { print color('bright_yellow'); }
		  elsif( $i == 1)  { print color('bright_green'); }
		  elsif( $i == 2)  { print color('bright_cyan'); }
		  elsif( $i == 3)  { print color('bright_blue'); }
		  elsif( $i == 4)  { print color('bright_magenta'); }
		  elsif( $i == 5)  { print color('bright_red'); }
      else             { print color('bright_black'); }
      
			print $header, "|__", $i - $start, "__| ", $_;
			$i ++;
			if( $i >= 6 and $i >= $opt->{clue} ) { last; }
		}
		print color('reset');
		print "\n"
	}
}

sub processList {
	my $listOpt = "$opt->{list}" . "$opt->{all}" . "$opt->{long}";
	if(    $listOpt =~ /^100$/ ) { system( "ls" ) };
	elsif( $listOpt =~ /^101$/ ) { system( "ls -l" ) };
	elsif( $listOpt =~ /^110$/ ) { system( "ls -a" ) };
	elsif( $listOpt =~ /^111$/ ) { system( "ls -al" ) };
}

sub processDB {
	$path_arr = $dir_db->sortDB();

	if( $debug ) {
		print "[INFO] ", "Finish sorting\n";
	}

	unless( $dir_db->checkLengthDB() ) {
		$path_arr = $dir_db->cutDownDB($path_arr);
	}
}

sub checkForFatalOptionErrors {
	my $exit_vote = 0;

	# Check for unkown args that were passed through by GetOptions
	foreach( @ARGV ) {
		if( /^-/ ) {
      print color('bold red'), "[ERROR] ", color('reset'), "unknown option: $_ \n";
      $exit_vote = 1;
		}
    if( /./ )	{
      print color('bold red'), "[ERROR] ", color('reset'), "unknown arguments $_ \n";
      $exit_vote = 1;
		}
	}

	if( $exit_vote == 1 ) {
		exit(1);
	}
}

sub saveDatabase {
	$dir_db->saveDB($db_file);
}

sub getHelp {
	if( $opt->{help} ) {
		print <<HELP;
    -p:    Declare the path. Default is the current directory.
    -s:    Save the path into the favorite directory database.
    -r:    Remove the path from the favorite directory database.
    -c:    Show "n" favorite directories from the most to the least. Default: n = 6.
		       For example, "-c 5" will print the most 5 favorite paths.
    -l:    (disabled) List files using `ls`.
    -a:    (disabled) Option for `ls`: ls -a.
    -g:    (disabled) Option for `ls`: ls -l.
    -h:    Get some help.
HELP
		exit(0);
	}
}
