{ config, pkgs, lib, repoPath, ...}:

{
  programs.firefox = {
    enable = true;
    profiles."default" = {
      id = 0;
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
      };
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        proton-pass
        proton-vpn
        ublock-origin
      ];
    };
  };

  # userChrome UI is privileged, so out-of-store symlinks work perfectly here.
  # You can continue editing your browser UI dynamically without rebuilding Nix.
  home.file.".mozilla/firefox/default/chrome/userChrome.css".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/firefox/chrome/userChrome.css";

  # userContent runs in a strict sandbox and breaks relative imports if symlinked out-of-store.
  # Since you never need to edit these imports, we define them statically here with absolute paths.
  home.file.".mozilla/firefox/default/chrome/userContent.css".text = ''
    @import "file://${config.home.homeDirectory}/.mozilla/firefox/default/chrome/matugen-github.css";
    @import "file://${config.home.homeDirectory}/.mozilla/firefox/default/chrome/matugen-youtube.css";
  '';
}
