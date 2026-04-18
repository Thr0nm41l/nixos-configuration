{ config, repoPath, ... }:

{
  programs.kitty.enable = true;

  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/kitty";
}
