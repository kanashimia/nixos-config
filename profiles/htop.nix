{
  programs.htop = {
    enable = true;
    treeView = true;
    hideUserlandThreads = true;
    highlightBaseName = true;
    showProgramPath = false;
    showCpuUsage = true;
    meters = {
      left = [
        "AllCPUs2"
        "Blank"
        { kind = "Memory"; mode = 2; }
      ];
      right = [
        "Uptime"
        "Blank"
        "Tasks"
        "LoadAverage"
        "Blank"
        { kind = "Swap"; mode = 2; }
      ];
    };
    fields = [
      "PID"
      "USER"
      "M_RESIDENT"
      "PERCENT_CPU"
      "PERCENT_MEM"
      "STATE"
      "COMM"
    ];
  };
}
