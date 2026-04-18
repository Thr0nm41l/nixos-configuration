{ config, lib, repoPath, ... }:

{ 
  xdg.configFile."rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/rofi/config.rasi";
}
