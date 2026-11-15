# zsh. Environment variables and PATH live with what needs them (home.sessionVariables,
# home.sessionPath), so every zsh gets them; direnv and starship hook themselves in.
{
  programs.zsh = {
    enable = true;

    history = {
      size = 50000;
      save = 10000;
      extended = true;
      expireDuplicatesFirst = true;
      # share, ignoreDups and ignoreSpace are on by default.
    };

    autocd = true;
    setOptions = [
      "HIST_VERIFY"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
    ];
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      l = "ls -lah";
      ll = "ls -lh";
      la = "ls -lAh";
    };
    sessionVariables.CLICOLOR = 1;

    # Completions come from the installed packages (share/zsh/site-functions).
    defaultKeymap = "emacs";
    initContent = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

      # Up/down search history by what's already typed
      autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      for k in '^[[A' '^[OA'; do bindkey "$k" up-line-or-beginning-search; done
      for k in '^[[B' '^[OB'; do bindkey "$k" down-line-or-beginning-search; done
    '';
  };
}
