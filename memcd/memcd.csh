#!/bin/csh
# ==================================================
# Filename: memcd.csh
# Date    : 2023-01-08
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

unalias memcd
alias memcd "$MYTOOL/memcd/memcd.pl"

echo "============================================"
set args=`echo $* | tr ' ' '\n' | awk '{printf("%s\\n", $0)}'`

# echo "ARGS: $args"

set non_option_regex="^[^- ]+";
set non_option=`echo "$args" | grep -oP "$non_option_regex"`

# echo "NON_OPTION: $non_option"

set option_regex='^-\w+$';
set option=`echo "$args" | grep -oP "$option_regex" | tr "\n" " "`

# echo "OPTION: $option"

set option_c=`echo "$option" | grep -oP "c"`
if ( "null$option_c" != "null" ) then
  memcd $option $non_option;
else
  memcd $option -p $non_option;
  if ( "null$non_option" != "null" ) 
    if ( -d $non_option ) then
      cd $non_option;
    endif
  endif
endif
echo "============================================"

set option_l=`echo "$option" | grep -oP "l"`
if ( "null$option_l" != "null" ) then
  ls -l;
	echo "============================================"
endif
# Reserved null line
