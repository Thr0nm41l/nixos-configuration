{ config, pkgs, repoPath, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.size = 10000;
    history.path = "$HOME/.zsh_history";
    history.ignoreAllDups = true;

    initContent = builtins.readFile ./zsh-init.sh;

    shellAliases = {
      edit = "sudo -E nvim -n";
      gitavail = "ssh-add $HOME/Documents/Важное/recovery_keys/GitHub/github_remote_keys/key";
      update = "sudo nixos-rebuild switch --flake ${repoPath}#nixosbtw";
      stop = "shutdown now";
      edconf = "sudo -E nvim ${repoPath}/configuration.nix";
      out = "loginctl terminate-user ${config.home.username}";
    };
    
    
    oh-my-zsh = {
        enable = true;
        plugins = [
          "git"                
        ];
        theme = "robbyrussell";
      };
    };

  home.sessionVariables = {
      hypr = "${repoPath}/config/sessions/hyprland/";
      programs = "${repoPath}/config/programs";
    };

}
