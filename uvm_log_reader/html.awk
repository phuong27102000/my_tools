#!/usr/bin/awk -f
# ==================================================
# Filename: html.awk 
# Date    : 2022-12-09
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

BEGIN{
  i = 0;
  result = 0; # 0: Passed, 1: Error, 2: Fatal
}
{
  if (match($0, "<col.*[0-9]+%")) {
    str = $0;
    if (i == 0)      sub("[0-9]+%","4%",str);  # Severity
    else if (i == 1) sub("[0-9]+%","10%",str); # File (Line)
    else if (i == 2) sub("[0-9]+%","6%",str);  # Time
    else if (i == 3) sub("[0-9]+%","10%",str); # Report Handler
    else if (i == 4) sub("[0-9]+%","10%",str); # Report Object
    else if (i == 5) sub("[0-9]+%","20%",str); # ID
    else if (i == 6) sub("[0-9]+%","40%",str); # Message
    file_arr[NR] = str;
    i++;
  }
  # Highlight UVM_ERROR, UVM_WARNING, UVM_FATAL
  else if (match($0, "^<tr")) {
    prev = $0;
    getline;
    curr = $0
    if (match(curr, "UVM_WARNING")) {
      sub("class=\"", "class=\"uvm_warning_row ", prev);
      if (result < 1) result = 1;
    }
    else if (match(curr, "UVM_ERROR")) {
      sub("class=\"", "class=\"uvm_error_row ", prev);
      if (result < 2) result = 2;
    }
    else if (match(curr, "UVM_FATAL")) {
      sub("class=\"", "class=\"uvm_fatal_row ", prev);
      if (result < 3) result = 3;
    }
    file_arr[NR-1] = prev;
    file_arr[NR] = curr;
  }
  else if (match($0, "^<td>[0-9]+</td>$")) {
    str = $0;
    sub(">", " class=\"num_cell\">", str);
    file_arr[NR] = str;
  }
  else file_arr[NR] = $0
}
END{
  for (idx = 1; idx <= NR; idx++) {
    if (result == 3)      sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#127384;",file_arr[idx]);
    else if (result == 2) sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#10071;",file_arr[idx]);
    else if (result == 1) sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#127383;",file_arr[idx]);
    else                  sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#128175;",file_arr[idx]);
    print file_arr[idx];
  }
}
