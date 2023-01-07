#!/bin/bash
# ==================================================
# Filename: memcd.bash
# Date    : 2023-01-07
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

echo "=================================================="
args=$(echo "$@" | tr " " "\n")

# echo "ARGS: $args"

non_option_regex="^[^- ]+";
non_option=$(echo "$args" | grep -oP "$non_option_regex");

# echo "NON_OPTION: $non_option"

option_regex='^-\w+$';
option=$(echo "$args" | grep -oP "$option_regex" | tr "\n" " ");

# echo "OPTION: $option"

if [[ $option =~ 'c' ]]; then
  $MYTOOL/memcd/memcd.pl $option $non_option;
else
  $MYTOOL/memcd/memcd.pl -p $non_option $option;
  if [[ ! -z $non_option ]] && [[ -d $non_option ]]; then
    cd $non_option;
  fi
fi

if [[ $option =~ 'l' ]]; then
  echo "=================================================="
  ls -l;
fi
