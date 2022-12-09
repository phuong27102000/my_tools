#!/bin/bash
# ==================================================
# Filename: uvm_log_reader.bash 
# Date    : 2022-12-09
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

PWD=$(pwd)
CONTAIN=uvm_log_reader
TEMPLATE=default.html

if [ -f "$PWD/$1".html ]; then
  read -p "--> This process will remove the file \""$PWD"/"$1".html\" ? [y/n] " yn
  case $yn in 
    [Yy]* ) echo "[INFO] Process continues.";;
    * )     echo "[INFO] Cancelled process."; exit;;
  esac
  rm "$PWD/$1".html
fi
if [ ! -f "$PWD/$1".html ]; then
  if [ ! -n $MYTOOL ]; then
    echo "[WARNING] Have not: set environment variable MYTOOL "$MYTOOL
    exit
  fi
  awk -f $MYTOOL/$CONTAIN/markdown.awk $PWD/$1 | pandoc -f markdown -t html --template $MYTOOL/$CONTAIN/$TEMPLATE > "$PWD/$1".html
  # awk -f $MYTOOL/$CONTAIN/markdown.awk $PWD/$1 | pandoc -f markdown -t html --template $MYTOOL/$CONTAIN/$TEMPLATE | awk -f $MYTOOL/$CONTAIN/html.awk > "$PWD/$1".html
fi
firefox "$PWD/$1".html
