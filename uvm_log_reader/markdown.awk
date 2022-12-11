#!/usr/bin/awk -f
# ==================================================
# Filename: markdown.awk 
# Date    : 2022-12-09
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

BEGIN{
  print "%UVM LOG SUMMARY"
  print "| Severity | File (Line) | Time | Report Handler | Report Object | ID | Message |"
  print "| -- | -- | -- | -- | -- | -- | -- |"
}
/^(# )*UVM_(INFO|ERROR|WARNING|FATAL).* @ /{
  str = $0;
  sub("^# ", "", str);                                       # Remove hash symbol if have
  match(str, "^UVM_(INFO|ERROR|WARNING|FATAL) ", arr)        # Get Severity
  sub("^UVM_(INFO|ERROR|WARNING|FATAL) ", arr[0]" | ", str)  # Severity | File (Line)
  sub("@", " | ", str);                                      # File (Line) | Time
  sub(": ", " | ", str);                                     # Time | Report Handler
  match(str, " \\[.*\\] ", arr);                             # Get [ID]
  id = arr[0];                                               # Get [ID]
  sub(" \\[", " | ", id);                                    # | ID]
  sub("\\] ", " | ", id);                                    # | ID |
  if (sub("@@", " | ", str) == 0)                            # Report Handler | Report Object
    sub(" \\[.*\\] ", " | "id, str);                         # Report Object | ID | Message
  else
    sub(" \\[.*\\] ", id, str);                              # Report Object | ID | Message
  match(str, "\\|[^\\|]+$", arr);
  gsub("\\. ", ". <br> ", arr[0]);
  sub("\\|[^\\|]+$", arr[0], str);
  print " | "str" | ";
}
