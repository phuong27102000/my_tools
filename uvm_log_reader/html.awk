#!/usr/bin/awk -f
# ==================================================
# Filename: html.awk 
# Date    : 2022-12-09
# Author  : Nguyen Ha Nhat Phuong
# Contact : phuong2710@gmail.com
# ==================================================

BEGIN{
  i = 0;
}
{
  if (match($0, "<col.*16%")) {
    str = $0;
    if (i == 0)      sub("16%","10%",str);
    else if (i == 1) sub("16%","10%",str);
    else if (i == 2) sub("16%","25%",str);
    else if (i == 3) sub("16%","10%",str);
    else if (i == 4) sub("16%","15%",str);
    else if (i == 5) sub("16%","30%",str);
    print str;
    i++;
  }
  else print $0
}
