{...}: let
  wrapper = "/Users/kyle/src/klutchell/private-skills/scripts/claude-scheduled.sh";
  logDir = "/Users/kyle/Library/Logs/claude-scheduled";

  # launchd gets a minimal PATH — include dirs needed for claude + nix tools
  path = builtins.concatStringsSep ":" [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/Users/kyle/.local/bin"
    "/Users/kyle/.nix-profile/bin"
    "/etc/profiles/per-user/kyle/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  # Mon=1 through Fri=5
  weekdays = [1 2 3 4 5];

  mkWeekdaySchedule = hour: minute:
    map (day: {
      Weekday = day;
      Hour = hour;
      Minute = minute;
    })
    weekdays;

  mkAgent = {
    name,
    skill,
    hour,
    minute,
  }: {
    serviceConfig = {
      Label = "com.kyle.${name}";
      ProgramArguments = ["/bin/bash" wrapper skill];
      StartCalendarInterval = mkWeekdaySchedule hour minute;
      StandardOutPath = "${logDir}/${name}-stdout.log";
      StandardErrorPath = "${logDir}/${name}-stderr.log";
      ProcessType = "Background";
      KeepAlive = false;
      LaunchOnlyOnce = false;
      EnvironmentVariables = {
        HOME = "/Users/kyle";
        PATH = path;
      };
    };
  };
in {
  system.activationScripts.postActivation.text = ''
    mkdir -p ${logDir}
    chown kyle:staff ${logDir}
  '';

  launchd.user.agents.claude-morning-briefing = mkAgent {
    name = "claude-morning-briefing";
    skill = "morning-zulip-catchup";
    hour = 8;
    minute = 30;
  };

  launchd.user.agents.claude-eod-summary = mkAgent {
    name = "claude-eod-summary";
    skill = "daily-accomplishment-summary";
    hour = 16;
    minute = 30;
  };
}
