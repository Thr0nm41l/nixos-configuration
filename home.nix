{ config, pkgs, ... }:

let
  vars = import ./variables.nix;

  # 1. Define the path to your programs directory
  programsDir = ./config/programs;

  # 2. Get the content of the directory
  files = builtins.readDir programsDir;

  # 3. Filter for directories only (ignoring regular files like .DS_Store or READMEs)
  directories = builtins.filter 
    (name: files.${name} == "directory") 
    (builtins.attrNames files);

  # 4. Map the directory names to import paths
  programImports = map (name: programsDir + "/${name}") directories;
in
{
  imports = [
    # sessions
    ./config/sessions/hyprland/default.nix
  ] ++ programImports; 

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = "25.11"; 
  
  home.packages = with pkgs; [
    # GTK themes
    adwaita-icon-theme
    adw-gtk3
    papirus-icon-theme

    # Rice dependencies (moved from configuration.nix)
    inotify-tools
    killall
    matugen
    ffmpeg
    grim
    playerctl
    satty
    slurp
    mpvpaper

    # User packages
    btop
    fzf
    direnv
    (python313.withPackages (ps: with ps; [ numpy pandas ]))
    telegram-desktop
    libreoffice-qt
    hunspell
    hunspellDicts.fr-any
    hunspellDicts.en_US
    obsidian
    obs-studio
    p7zip
    kdePackages.okular
    fastfetch
    jetbrains.idea-oss
    gnome-tweaks
    pkgsCross.mingwW64.stdenv.cc
    bottles
    qbittorrent
    jdk8
    steam-run
    discord
    teamspeak6-client
    protonmail-desktop
    proton-pass
    mission-center
    pavucontrol
    piper
  ];

  # set cursor 
  home.pointerCursor = 
  let 
    getFrom = url: hash: name: {
        gtk.enable = true;
        x11.enable = true;
        name = name;
        size = 24;
        package = 
          pkgs.runCommand "moveUp" {} ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.fetchzip {
              url = url;
              hash = hash;
            }}/dist $out/share/icons/${name}
          '';
      };
  in
    getFrom 
      "https://github.com/yeyushengfan258/ArcMidnight-Cursors/archive/refs/heads/main.zip"
      "sha256-VgOpt0rukW0+rSkLFoF9O0xO/qgwieAchAev1vjaqPE=" 
      "ArcMidnight-Cursors";

  # Force the dark color scheme and explicitly set GTK3 theme in dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
    };
  };
  
  home.sessionVariables = {
    # Left intentionally blank to prevent GTK variable overrides
  };

  services.easyeffects.enable = true;  

  gtk = {
    enable = true;
    
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "adw-gtk3-dark";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };
  
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true; 
  
  home.file = {
    ".local/share/fonts/" = {
      source = config/fonts; 
      recursive = true;
    };
  };

}
