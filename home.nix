{ config, pkgs, lib, inputs, imports, ... }:

{
  home.username = "ice";
  home.homeDirectory = "/home/ice";
  home.stateVersion = "25.11";

  home.enableNixpkgsReleaseCheck = false;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "iceol8ed";
        email = "t.leonidius@gmail.com";
      };
      credential = {
        helper = "store";
      };
    };
  };  

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      keyboardShortcut
    ];
    enabledCustomApps = with spicePkgs.apps; [
    ];
    enabledSnippets = with spicePkgs.snippets; [
    ];
  };

  programs.yazi = {
    enable = true;
    
    # Enables shell integrations for automatic directory switching
    enableZshIntegration = true; 
    enableBashIntegration = true;

    # Maps directly to your yazi.toml file
    settings = {
      opener = {
        open = [
          { 
            run = "xdg-open \"$@\""; 
            orphan = true; 
            desc = "Open"; 
            for = "unix"; 
          }
        ];
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot"; # References foot from your nixpkgs
      };

      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        prompt = "bac2deff";
        placeholder = "7f849cff";
        input = "cdd6f4ff";
        match = "89b4faff";
        selection = "585b70ff";
        "selection-text" = "cdd6f4ff";
        "selection-match" = "89b4faff";
        counter = "7f849cff";
        border = "89b4faff";
      };
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      save-position-on-quit = "yes"; # Saves your place when you exit
      speed = 2.0;                   # Sets default playback speed to 2x
      fullscreen = "yes";            # Starts mpv in fullscreen mode
      gpu-context = "wayland";       # Optimized for Wayland
      sub-scale = 0.5;               # Adjusts subtitle size
    };
  };
  
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
      };

      cursor = {
        style = "beam";
      };

      colors = {
        background = "000000";
      };
    };
  };
  
  wayland.windowManager.sway = {
    enable = true;
    # Ensures Sway is integrated with systemd and GTK apps 
    wrapperFeatures.gtk = true; 
    config = rec {
      modifier = "Mod4"; # $mod 
      terminal = "foot"; # $term 
      menu = "fuzzel -I"; # $menu 
      bars = [];

      # --- Input --- 
      input = {
        "*" = { natural_scroll = "enabled"; };
        "type:keyboard" = {
          xkb_layout = "us,gr";
          xkb_options = "grp:toggle";
        };
      };

      # --- Visuals & Decoration --- 
      window = {
        border = 0; # or 1, 2 etc. "none" is usually 0
        titlebar = false;
      };
      floating = {
        border = 0;
        titlebar = false;
      };
    
  # Note on gaps: Home Manager uses gaps.inner and gaps.outer 
  # which you already have, and that should be correct.
      gaps = {
        inner = 0;
        outer = 0;
      };
      # --- Startup (Exec) --- [cite: 1, 3]
      startup = [
        { command = "autotiling-rs"; always = true; }
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }
        { command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
        { command = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"; always = true; }
        { command = "wl-clip-persist --clipboard regular"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = "swaymsg workspace 1"; } # This line ensures you start on workspace 1
        # Note: Paths like /usr/lib/ don't exist in NixOS. 
        # We use the pkgs variable to point to the correct store path. 
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      ];

      # --- Keybindings --- [cite: 4, 5, 8, 9]
      keybindings = lib.mkOptionDefault {
        # Navigation
        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+k" = "focus up";
        "${modifier}+j" = "focus down";
        
        # Movement
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+j" = "move down";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";

        # Move focused window to workspace AND switch focus to that workspace
        "${modifier}+Shift+1" = "move container to workspace number 1; workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2; workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3; workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4; workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5; workspace number 5";

        # Apps
        "${modifier}+q" = "kill";
        "${modifier}+b" = "exec chromium";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+f" = "exec ${terminal} yazi";
        "${modifier}+n" = "exec ${terminal} bluetui";
        "${modifier}+Shift+n" = "exec ${terminal} wiremix";
        "${modifier}+space" = "exec ${menu}";
        "${modifier}+m" = "exec GTK_CSD=0 localsend_app";
        "${modifier}+s" = "exec spotify";
        "${modifier}+Shift+f" = "fullscreen";
        "${modifier}+Shift+t" = "floating toggle";

        # Clipboard / Screenshots
        "${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${modifier}+Shift+p" = "exec grim ~/Desktop/$(date +'%Y-%m-%d-%H%M%S_grim.png')";
        "${modifier}+Shift+v" = "exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";

        # System
        "${modifier}+Escape" = "exec systemctl suspend";
        "${modifier}+Shift+Escape" = "exec shutdown now";
        "${modifier}+o" = "output * dpms off";
        "${modifier}+Shift+o" = "output * dpms on";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 3%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 3%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        # Wtype Macros
        "${modifier}+c" = "exec wtype -M ctrl -k Insert -m ctrl";
        "${modifier}+v" = "exec wtype -M shift -k Insert -m shift";
        "${modifier}+a" = "exec wtype -M ctrl -k a -m ctrl";
        "${modifier}+w" = "exec wtype -M ctrl -k w -m ctrl";
        "${modifier}+backspace" = "exec wtype -M ctrl -k u -m ctrl";
      };
      # --- Seat / Cursor --- 
      seat = {
        "seat0" = { xcursor_theme = "Bibata-Modern-Classic 20"; };
        "*" = { hide_cursor = "3000"; };
      };

      floating.modifier = "${modifier} normal";
    };
  };
  
  programs.helix = {
    enable = true;
    
    # 1. Select your custom theme name
    settings = {
      theme = "tokyonight_transparent";
      editor = {
        whitespace.render = {
          tab = "none";
        };
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };

    # 2. Define the custom theme
    themes = {
      tokyonight_transparent = {
        inherits = "tokyonight";
        # Removing the background color enables transparency
        "ui.background" = { }; 
      };
    };
  };

  home.packages = [
    inputs.lobster.packages.${pkgs.system}.lobster
  ];

  xdg.configFile."lobster/lobster_config.sh".text = ''
    # Replicates your lobster_config.sh options
    history=true
  '';
}

