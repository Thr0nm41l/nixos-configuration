# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  vars = import ./variables.nix;
in
{
  # Imports
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # System packages
  environment.systemPackages = with pkgs; [
    quickshell
    power-profiles-daemon
    git
    wget
    curl
  ];

  environment.pathsToLink = [ "/share/gsettings-schemas" ];

  # User accounts and security
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" "libvirtd"];
    packages = with pkgs; [
    #  thunderbird
    ];
    useDefaultShell = true;
    shell = pkgs.zsh;
  };    

  users.defaultUserShell = pkgs.zsh;
  system.userActivationScripts.zshrc = "touch .zshrc";

  # Uncomment to disable password prompt for all sudo commands
  # security.sudo.extraRules = [
  #   {
  #     users = [ vars.username ];
  #     commands = [
  #       {
  #         command = "ALL";
  #         options = [ "NOPASSWD" ];
  #       }
  #     ];
  #   }
  # ];

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  }; 
  # Program configurations
  programs.zsh.enable = true;

  programs.adb.enable = true;

  programs.dconf = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
  };
  programs.gamemode.enable = true;

  # Desktop environment, window managers and theme
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  
  # Hyprland
  programs.hyprland.enable = true;
  
  # XDG Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  console.keyMap = "fr";

  # Fonts
  fonts.packages = with pkgs; [
    udev-gothic-nf
    noto-fonts
    liberation_ttf
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono
  ]; 

  fonts.fontconfig = {
    enable = true;
    hinting.style = "slight"; 
    subpixel.rgba = "rgb"; 
  };

  # Flatpak
  services.flatpak.enable = true;

  # Environment Variables
  # environment.variables.XDG_DATA_DIRS = lib.mkForce "/home/thron/.nix-profile/share:/run/current-system/sw/share";

  # Networking and time
  networking.hostName = vars.hostname;
  
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; 
  };
   # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Audio and system services
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig."51-mic-restore" = {
      "monitor.alsa.rules" = [
        # Disable NVIDIA HDMI audio input (detected as a microphone on some systems)
        {
          matches = [{ "api.alsa.card.name" = "~HDA NVidia*"; }];
          actions = {
            update-props = {
              "device.disabled" = true;
            };
          };
        }
        # Set default volume for the real microphone (Intel HDA)
        # Matched by card name to avoid ID shifts on reboot
        {
          matches = [{ "api.alsa.card.name" = "~HD-Audio Generic*"; }];
          actions = {
            update-props = {
              "node.pause-on-idle" = false;
              "audio.volume" = 0.75;
            };
          };
        }
      ];
    };
  };
  services.blueman.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Power Management Services
  services.power-profiles-daemon.enable = true;

  # Logitech mouse configuration
  services.ratbagd.enable = true;

  # Nix settings and maintenance
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };
  boot = {
    plymouth = {
      enable = true;
      theme = "simple";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-simple";
          version = "1.0";
          
          # CHANGE THIS to the actual path of your custom theme folder
          src = ./config/programs/plymouth/simple;

          installPhase = ''
            mkdir -p $out/share/plymouth/themes/simple
            cp -r * $out/share/plymouth/themes/simple/
            
            # This dynamically replaces the @out@ placeholder with the real Nix store path
            substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
              --replace "@out@" "$out"
          '';
        })      
	];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "intel_pstate=active"
      "tsc=reliable"
    ];
    
  };
  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
	
  # Bootloader and kernel
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  # Kernel Packages and Optimization
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  # hardware.cpu.intel.updateMicrocode is handled by hardware-configuration.nix via lib.mkDefault

  boot.kernelModules = [ "tcp_bbr" ]; # FIX: Network Congestion Control (Helps with packet jitter)
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.wmem_max" = 1073741824;
    "net.core.rmem_max" = 1073741824;
    "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
  };

  # FIX: Force CPU to run at max clock speed to prevent frame-time jitter
  powerManagement.cpuFreqGovernor = "performance";

  # ==========================================
  # GPU / GRAPHICS CONFIGURATION (ADDED)
  # ==========================================

  # Enable OpenGL/Vulkan (renamed to hardware.graphics in 24.11+)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam/CS2
  };

  # Load NVIDIA Drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption after suspend/wake.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures.
    # We set to false here for maximum stability on the mobile 3050.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Select the stable driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME CONFIGURATION (Hybrid Graphics)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      
      # Bus IDs derived from your lspci output
      # NVIDIA: 01:00.0 -> PCI:1:0:0
      # Intel: 00:02.0 -> PCI:0:2:0
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  system.stateVersion = "25.11"; 
}
