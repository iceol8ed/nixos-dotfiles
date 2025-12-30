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
    enableZshIntegration = true; 
      settings = {
      opener = {
        extract = [
          {
            run = ''unzip "$1" -d "''${1%.*}"'';
            desc = "Extract here";
            for = "unix";
          }
        ];
        edit = [
          { run = ''hx "$@"''; block = true; desc = "Helix"; }
        ];
        web-browser = [
        { 
          run = ''xdg-open "$@"''; 
          block = false; 
          orphan = true; 
          desc = "Open in Default Browser"; 
        }
        ];
      };

      open = {
        rules = [
          { mime = "text/*"; use = "edit"; }
          { mime = "application/zip"; use = "extract"; }
          { mime = "application/x-7z-compressed"; use = "extract"; }
          { mime = "application/x-rar"; use = "extract"; }
          { name = "*"; use = "web-browser"; }
        ];
      };
    };
  };
    
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot"; 
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
      save-position-on-quit = "yes"; 
      speed = 2.0;                   
      fullscreen = "yes";            
      gpu-context = "wayland";       
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
    wrapperFeatures.gtk = true; 
    config = rec {
      modifier = "Mod4"; 
      terminal = "foot";  
      menu = "fuzzel -I";  
      bars = [];

      input = {
        "*" = { natural_scroll = "enabled"; };
        "type:keyboard" = {
          xkb_layout = "us,gr";
          xkb_options = "grp:toggle";
        };
      };

      output = {
        "HDMI-A-1" = {
          mode = "1920x1080";
          pos = "0 0";
          transform = "270";
        };
        "DP-2" = {
          mode = "2560x1440";
          pos = "1080 0"; 
        };
      };

      workspaceOutputAssign = [
        { workspace = "5"; output = "HDMI-A-1"; }
      ];

      window = {
        border = 0; 
        titlebar = false;
      };
      floating = {
        border = 0;
        titlebar = false;
      };
    
      gaps = {
        inner = 0;
        outer = 0;
      };

      startup = [
        { command = "autotiling-rs"; always = true; }
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }
        { command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
        { command = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"; always = true; }
        { command = "wl-clip-persist --clipboard regular"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        { command = "swaymsg focus output DP-2"; }
        { command = "swaymsg workspace 1"; }
      ];

      keybindings = lib.mkOptionDefault {
        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+k" = "focus up";
        "${modifier}+j" = "focus down";
        
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+j" = "move down";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";

        "${modifier}+Shift+1" = "move container to workspace number 1; workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2; workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3; workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4; workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5; workspace number 5";

        "${modifier}+q" = "kill";
        "${modifier}+b" = "exec helium";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+f" = "exec ${terminal} yazi";
        "${modifier}+n" = "exec ${terminal} bluetui";
        "${modifier}+Shift+n" = "exec ${terminal} wiremix";
        "${modifier}+space" = "exec ${menu}";
        "${modifier}+m" = "exec GTK_CSD=0 localsend_app";
        "${modifier}+s" = "exec spotify";
        "${modifier}+g" = "exec xdg-open https://gemini.google.com";
        "${modifier}+y" = "exec xdg-open https://youtube.com";
        "${modifier}+Shift+f" = "fullscreen";
        "${modifier}+Shift+t" = "floating toggle";

        "${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${modifier}+Shift+p" = "exec grim ~/Desktop/$(date +'%Y-%m-%d-%H%M%S_grim.png')";
        "${modifier}+Shift+v" = "exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";

        "${modifier}+Escape" = "exec systemctl suspend";
        "${modifier}+Shift+Escape" = "exec shutdown now";
        "${modifier}+o" = "output * dpms off";
        "${modifier}+Shift+o" = "output * dpms on";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 3%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 3%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        "XF86AudioStop" = "exec playerctl stop";

        "${modifier}+c" = "exec wtype -M ctrl -k Insert -m ctrl";
        "${modifier}+v" = "exec wtype -M shift -k Insert -m shift";
        "${modifier}+a" = "exec wtype -M ctrl -k a -m ctrl";
        "${modifier}+w" = "exec wtype -M ctrl -k w -m ctrl";
        "${modifier}+t" = "exec wtype -M ctrl -k t -m ctrl";
        "${modifier}+backspace" = "exec wtype -M ctrl -k u -m ctrl";
      };

      seat = {
        "seat0" = { xcursor_theme = "Bibata-Modern-Classic 20"; };
        "*" = { hide_cursor = "3000"; };
      };

      floating.modifier = "${modifier} normal";
    };
  };
  
  programs.helix = {
    enable = true;
    
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

    themes = {
      tokyonight_transparent = {
        inherits = "tokyonight";
        "ui.background" = { }; 
      };
    };
  };

  home.packages = [
    inputs.lobster.packages.${pkgs.system}.lobster
    pkgs.nur.repos.Ev357.helium
  ];

  xdg.configFile."lobster/lobster_config.sh".text = ''
    # Replicates your lobster_config.sh options
    history=true
  '';
}

