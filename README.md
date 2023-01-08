# my_tools
Some tools I need for my VLSI career
- Steps to use:
  - Set environment variable `MYTOOL` as the path to `my_tools` (the folder contains this README file)

### uvm_log_reader
- Compose a UVM log file into an HTML file to view with a web browser.
- Recommend using with UVM_LOG mode.
- Steps to use:
  - Alias `ulr` as `$MYLOG/uvm_log_reader/uvm_log_reader.bash`

### memcd
- Memorize the directories that the user has visited
- Steps to use:
  - Alias `mcd` as `source $MYTOOL/memcd/memcd.bash`
- Some aliases you should have:
```
alias cs="mcd -sl"
alias cb="mcd -bsl"
alias cc="mcd -c"
alias q="mcd -l ../"
alias qq="mcd -l ../../"
alias qqq="mcd -l ../../../"
```

