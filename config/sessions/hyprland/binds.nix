{ config, pkgs, ... }: 

{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$terminal" = "kitty";

    gesture = [
      "3, horizontal, workspace"
    ];
    
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
    
    binde = [
      "$mainMod&SHIFT_L, left, resizeactive,-50 0"
      "$mainMod&SHIFT_L, right, resizeactive,50 0"
      "$mainMod&SHIFT_L, up, resizeactive,0 -50"
      "$mainMod&SHIFT_L, down, resizeactive,0 50"
    ];
      
    bindl = [
      ", Caps_Lock, exec, sleep 0.1 && swayosd-client --caps-lock"

      "$mainMod, P, exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", xf86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ", xf86audiomute, exec, swayosd-client --output-volume mute-toggle"
      ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"

      ", Print, exec, ~/.config/hypr/scripts/screenshot.sh"
      "SHIFT_L, Print, exec, ~/.config/hypr/scripts/screenshot.sh --edit"
      "SUPER, Print, exec, ~/.config/hypr/scripts/screenshot.sh --full"
      "SUPER SHIFT_L, Print, exec, ~/.config/hypr/scripts/screenshot.sh --full --edit"

      ", XF86PowerOff, exec, bash ~/.config/hypr/scripts/lock.sh"
    ];
    
    bindel = [
      ", xf86audiolowervolume, exec, swayosd-client --output-volume lower"
      ", xf86audioraisevolume, exec, swayosd-client --output-volume raise"
      
      "$mainMod, L, exec, bash ~/.config/hypr/scripts/lock.sh" 
			 
    ];
    
    bind = [
      "$mainMod, SPACE, exec, bash ~/.config/hypr/scripts/rofi_show.sh drun"
      "ALT, TAB, exec, bash ~/.config/hypr/scripts/rofi_show.sh window"
      "$mainMod, V, exec, bash ~/.config/hypr/scripts/rofi_clipboard.sh"
      "$mainMod, A, exec, swaync-client -t -sw"
      "$mainMod&SHIFT_L, F, togglefloating,"
      "$mainMod, Q, killactive,"

      # Quickshell windows
      "$mainMod&SHIFT_L, S, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle stewart"
      "$mainMod, M, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle music"
      "$mainMod, B, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle battery"
      "$mainMod, W, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle wallpaper"
      "$mainMod, S, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle monitors"
      "$mainMod, N, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle network"
      "$mainMod&SHIFT_L, T, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle focustime"
      "$mainMod, H, exec, bash ~/.config/hypr/scripts/qs_manager.sh toggle guide"

      "$mainMod, F, exec, firefox"
      "$mainMod, E, exec, nautilus"
      "$mainMod, T, exec, Telegram"
      "$mainMod, D, exec, discord"
      "$mainMod, O, exec, obsidian"
      "$mainMod, RETURN, exec, $terminal"

      "ALT, F4, exec, hyprctl dispatch killactive"

      "$mainMod&CTRL, left, movewindow, l"
      "$mainMod&CTRL, right, movewindow, r"
      "$mainMod&CTRL, up, movewindow, u"
      "$mainMod&CTRL, down, movewindow, d"

      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # AZERTY unshifted number row: & é " ' ( - è _ ç à
      "$mainMod, ampersand,   exec, ~/.config/hypr/scripts/qs_manager.sh 1"
      "$mainMod, eacute,      exec, ~/.config/hypr/scripts/qs_manager.sh 2"
      "$mainMod, quotedbl,    exec, ~/.config/hypr/scripts/qs_manager.sh 3"
      "$mainMod, apostrophe,  exec, ~/.config/hypr/scripts/qs_manager.sh 4"
      "$mainMod, parenleft,   exec, ~/.config/hypr/scripts/qs_manager.sh 5"
      "$mainMod, minus,       exec, ~/.config/hypr/scripts/qs_manager.sh 6"
      "$mainMod, egrave,      exec, ~/.config/hypr/scripts/qs_manager.sh 7"
      "$mainMod, underscore,  exec, ~/.config/hypr/scripts/qs_manager.sh 8"
      "$mainMod, ccedilla,    exec, ~/.config/hypr/scripts/qs_manager.sh 9"
      "$mainMod, agrave,      exec, ~/.config/hypr/scripts/qs_manager.sh 10"

      "$mainMod SHIFT, ampersand,   exec, ~/.config/hypr/scripts/qs_manager.sh 1 move"
      "$mainMod SHIFT, eacute,      exec, ~/.config/hypr/scripts/qs_manager.sh 2 move"
      "$mainMod SHIFT, quotedbl,    exec, ~/.config/hypr/scripts/qs_manager.sh 3 move"
      "$mainMod SHIFT, apostrophe,  exec, ~/.config/hypr/scripts/qs_manager.sh 4 move"
      "$mainMod SHIFT, parenleft,   exec, ~/.config/hypr/scripts/qs_manager.sh 5 move"
      "$mainMod SHIFT, minus,       exec, ~/.config/hypr/scripts/qs_manager.sh 6 move"
      "$mainMod SHIFT, egrave,      exec, ~/.config/hypr/scripts/qs_manager.sh 7 move"
      "$mainMod SHIFT, underscore,  exec, ~/.config/hypr/scripts/qs_manager.sh 8 move"
      "$mainMod SHIFT, ccedilla,    exec, ~/.config/hypr/scripts/qs_manager.sh 9 move"
      "$mainMod SHIFT, agrave,      exec, ~/.config/hypr/scripts/qs_manager.sh 10 move"
     ]; 
  };
}
