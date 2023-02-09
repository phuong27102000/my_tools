#! /usr/bin/env perl
# ==================================================
# Filename: DirDB.pl
# Date    : 2023-01-05
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

# Database example:
# ==================================================
# /home/somebody/somewhere/ :: 2 :: preferred
# /home/someone/somewhere/ :: 0 :: -
# ==================================================

package DirDB;

use strict;
use warnings;

use constant TRUE => 1;
use constant FALSE => 0;

# ==================================================
# Default value
my $pk = "DirDB";

# Default Database line-number limit = n -> store n-1
#                 favorite and the previous directory
my $DBlimit_def = 20;

# Default: non-debug mode
my $debug_def   = 0;

# Default: The number of successive times this path has not been chose
my $forgotten_times_def = 5;

# Default: Be at least a number of call time to be in the forgotten list
my $forgotten_thres_def = 3;

# ==================================================
# Subroutines
# *** new
#     ___ Constructor for this class
# *** loadDB: i - $filename
#     ___ Load the database file and save to the
# 				object
# *** saveDB: i - $filename
#     ___ Save the database from the object to the
#      		database file
# *** cutDownDB: i - $path_arr
#								 o - $ret_path_arr
#     ___ Shorten the database to the proper size
# *** sortDB: o - $path_arr
#     ___ Sort the database
# *** addPathToDB: i - $path
#     ___ Add the new/old path to the database
# *** removePath: i - $path
#     ___ Remove the old path from the database
# *** checkLengthDB: o - TRUE/FALSE
#     ___ Check if the database size is proper
# *** getDBSize: o - $len
#     ____ Return the database size
# *** getClassName
#     ___ Return the class name
# ==================================================

sub new {
	my $class = shift;
	my %args = @_;
	my $this = \%args;
	bless $this, $class;

	$this->{DBlimit}         = $DBlimit_def         unless( defined $this->{DBlimit} );
	$this->{debug}           = $debug_def           unless( defined $this->{debug} );
	$this->{forgotten_times} = $forgotten_times_def unless( defined $this->{forgotten_times} );
	$this->{forgotten_thres} = $forgotten_thres_def unless( defined $this->{forgotten_thres} );

	return $this;
}

sub loadDB {
	my $this = shift;
	my $filename = shift;
	my %database = ();
	my @line_word = ();

	unless( -e $filename ) { system("touch $filename"); }
	if( -z $filename ) {return 0;}

	open( my $in, "<", $filename ) or die "[ERROR] Can't open $filename";
	if( $this->{debug} ) {
		print "[INFO] ", "Loading database...\n";
	}

	while( <$in> ) {
		chomp;
		@line_word = split(/\s::\s/);
		if( $this->{debug} ) {
			print "[INFO] ", "$pk ", "-> Each line: @line_word \n";
		}
		$database{$line_word[0]} = [ @line_word[1..$#line_word] ]
	}
	$this->{DB} = \%database;
	if( $this->{debug} ) {
		print "[INFO] ", "Finish loading database...\n";
	}
}

sub saveDB {
	my $this = shift;
	my $filename = shift;

	open( my $out, ">", $filename ) or die "[ERROR] Can't open $filename";

	foreach( keys %{$this->{DB}} ) {
		my $separator = $";
		$" = " :: ";
		print $out "$_ :: @{$this->{DB}->{$_}}" . "\n";
		$" = $separator;
	}
}

sub cutDownDB {
	my $this = shift;
	my $path_arr = shift;
	my $offset = 0;
	my @ret_path_arr = ();

	if( @$path_arr > $this->{DBlimit} ) {
		$offset = @$path_arr - $this->{DBlimit};
		@ret_path_arr = @{$path_arr}[$offset..$#$path_arr];
	}

	if( $this->{debug} ) {
		print "[INFO] ", "$pk -> ", "Before deleting\n";
	}
	$offset--;
	foreach( @$path_arr[0..$offset] ) {
		delete( $this->{DB}->{$_} );
	}
	return \@ret_path_arr;
}

sub sortDB {
	my $this = shift;
	my @path_arr = ();
	my $smallest = 0;

	foreach( sort {
									if( $this->{DB}->{$b}->[1] eq $this->{DB}->{$a}->[1] ) {
										$this->{DB}->{$b}->[0] <=> $this->{DB}->{$a}->[0]
									} else {
										if( $this->{DB}->{$b}->[1] eq "preferred" ) {
											1;
										} else {
											-1;
										}
									}
								} keys %{$this->{DB}} ) {
		$path_arr[@path_arr] = $_;
		# $smallest = $this->{DB}->{$_}->[0] if( $smallest > $this->{DB}->{$_}->[0] ) ;
	}

  foreach( 0..$#path_arr ) {
    # $this->{DB}->{$path_arr[$_]}->[0] -= $smallest;
    $this->{DB}->{$path_arr[$_]}->[2] ++;
    unless ( $this->{DB}->{$path_arr[$_]}->[2] < $this->{forgotten_times} ) {
      $this->{DB}->{$path_arr[$_]}->[0] -- unless( $this->{DB}->{$path_arr[$_]}->[0] < $this->{forgotten_thres} );
      $this->{DB}->{$path_arr[$_]}->[2] = 0;
    }
  }

	return \@path_arr;
}

sub addPathToDB {
	my $this = shift;
	my $path = shift;
	my @arg = @_;

	if( defined $this->{DB}->{$path} ) {
		$this->{DB}->{$path}->[0] ++;
	} else {
		$this->{DB}->{$path} = [ () ];
		$this->{DB}->{$path}->[0] = 1;
	}

	my $i = 1;
	foreach( @arg ) {
		$this->{DB}->{$path}->[$i] = $_;
    $i ++;
	}

  # Forgotten times starts at 0
	$this->{DB}->{$path}->[$i] = $_;
}

sub removePath {
	my $this = shift;
	my $path = shift;


	if( defined $this->{DB}->{$path} ) {
		delete( $this->{DB}->{$path} ) ;
	}
}

sub checkLengthDB {
	my $this = shift;
	my $act = $this->getDBSize();
	my $ref = $this->{DBlimit};

	if( $act > $ref ) {
		if( $this->{debug} ) {
			print "[WARNING] ", "$pk -> ", "Over limit database size: $act > $ref", "\n";
		}
		return FALSE;
	}
	return TRUE;
}

sub getDBSize {
	my $this = shift;
	my @tmp = keys %{ $this->{DB} };
	my $len = @tmp;
	if( $this->{debug} ) {
		print "[INFO] ", "$pk -> ", "Length: $len", "\n"
	}
	return $len
}

sub getClassName {
	return $pk;
}

# ==================================================
1;
