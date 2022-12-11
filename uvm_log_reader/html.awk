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
    if (i == 0)      sub("[0-9]+%","3%",str);  # Severity
    else if (i == 1) sub("[0-9]+%","10%",str); # File (Line)
    else if (i == 2) sub("[0-9]+%","12%",str); # Time
    else if (i == 3) sub("[0-9]+%","10%",str); # Report Handler
    else if (i == 4) sub("[0-9]+%","15%",str); # Report Object
    else if (i == 5) sub("[0-9]+%","20%",str); # ID
    else if (i == 6) sub("[0-9]+%","30%",str); # Message
    file_arr[NR] = str; # print str;
    i++;
  }
  else {
    # Highlight UVM_ERROR, UVM_WARNING, UVM_FATAL
    if (match($0, "^<tr")) {
      prev = $0;
      getline;
      curr = $0
      if (match(curr, "UVM_ERROR")) {
        sub(">", " style=\"background-color:#ffcccb\">", prev)
        if (result < 2) result = 2;
      }
      else if (match(curr, "UVM_WARNING")) {
        sub(">", " style=\"background-color:#e8e8e8\">", prev)
        if (result < 1) result = 1;
      }
      else if (match(curr, "UVM_FATAL")) {
        sub(">", " style=\"background-color:#000000; color:#ffffff\">", prev)
        if (result < 3) result = 3;
      }
      # print prev
      # print curr
      file_arr[NR-1] = prev;
      file_arr[NR] = curr;
    }
    # else print $0
    else file_arr[NR] = $0
  }
}
END{
  for (idx in file_arr) {
    if (result == 3)      sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#127384;",file_arr[idx]);
    else if (result == 2) sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#10071;",file_arr[idx]);
    else if (result == 1) sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#127383;",file_arr[idx]);
    else                  sub("UVM LOG SUMMARY","UVM LOG SUMMARY \\&#128175;",file_arr[idx]);
    print file_arr[idx];
  }
}
