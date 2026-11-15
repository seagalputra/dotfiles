# fish. Environment variables and PATH live with what needs them (home.sessionVariables,
# home.sessionPath), so every fish gets them; direnv and starship hook themselves in.
# History, completion, prefix history search and `cd` history (prevd/nextd/cdh) are
# fish defaults; typing a directory (`..`, `src/`) cds into it.
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
    shellAbbrs = {
      "..." = "cd ../..";
      l = "ls -lah";
      ll = "ls -lh";
      la = "ls -lAh";
    };
  };

  home.sessionVariables.CLICOLOR = 1;
}
