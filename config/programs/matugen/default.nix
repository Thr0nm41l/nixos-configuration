{ config, pkgs, lib, repoPath, ... }:

{ 
  xdg.configFile."matugen".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/matugen";
}
