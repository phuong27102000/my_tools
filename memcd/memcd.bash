#!/bin/bash
# ==================================================
# Filename: memcd.bash
# Date    : 2023-01-07
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

unalias memcd
alias memcd="$MYTOOL/memcd/memcd.pl"

echo "============================================"
args=$(echo "$@" | tr " " "\n")

# echo "ARGS: $args"

non_option_regex="^[^- ]+";
non_option=$(echo "$args" | grep -oP "$non_option_regex");

# echo "NON_OPTION: $non_option"

option_regex='^-\w+$';
option=$(echo "$args" | grep -oP "$option_regex" | tr "\n" " ");

# echo "OPTION: $option"

if [[ $option =~ 'c' ]]; then
  memcd $option $non_option;
else
  memcd $option -p $non_option;
  if [[ ! -z $non_option ]] && [[ -d $non_option ]]; then
    cd $non_option;
  else
    the_path_to_cd=$(memcd -m -p $non_option);
    if [[ ! -z $the_path_to_cd ]] && [[ -d $the_path_to_cd ]]; then
      cd $the_path_to_cd;
    else
      option=$(echo "$option" | tr -d "l");
    fi
  fi
fi
echo "============================================"

if [[ $option =~ 'l' ]]; then
  ls -l;
	echo "============================================"
fi
