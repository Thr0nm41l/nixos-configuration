{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      donjayamanne.githistory
      mechatroner.rainbow-csv
      redhat.vscode-yaml
      jnoortheen.nix-ide
    ];
  };
}
