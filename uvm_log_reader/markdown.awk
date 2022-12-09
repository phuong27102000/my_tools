#!/usr/bin/awk -f
# ==================================================
# Filename: markdown.awk 
# Date    : 2022-12-09
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

BEGIN{
  print "%LOG SUMMARY"
  print "| Severity | Time | Report Handler | Report Object | ID | Message |"
  print "| -- | -- | -- | -- | -- | -- |"
}
/^UVM_(INFO|ERROR|WARNING|FATAL).* @ /{
  str = $0;
  sub("@"    , " | " , str);
  sub(": "   , " | " , str);
  if (sub("@@"   , " | " , str) == 0)
    sub(" \\[" , " | | " , str);
  else
    sub(" \\[" , " | " , str);
  sub("\\] " , " | " , str);
  print " | "str" | ";
}
