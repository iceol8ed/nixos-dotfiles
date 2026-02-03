{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;

  networking.firewall = {
  allowedTCPPorts = [ 53317 ];
  allowedUDPPorts = [ 53317 ];
  };

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Athens";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
    tempDir = "/var/spool/cups/tmp"; 
  };

  documentation.nixos.enable = false;
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.gamemode.enable = true;

  system.autoUpgrade = {
    enable = true;

    flake = "/etc/nixos";

    dates = "weekly";

    randomizedDelaySec = "30min";
    operation = "switch";
    allowReboot = false;

    flags = [ "-L" ];
  };
  
  users.users.ice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "render" "dialout" "lp" ]; # Enable ‘sudo’ for the user.
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword=false;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  
  programs.zsh = {
    enable = true;
    loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
    '';
    interactiveShellInit = ''
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[path]=none
    ZSH_HIGHLIGHT_STYLES[path_prefix]=none
    ZSH_HIGHLIGHT_STYLES[path_separator]=none
    ZSH_HIGHLIGHT_STYLES[precommand]=none
    '';
    promptInit = ''
    export PS1="%~ > "
    '';
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      nos = "sudo nixos-rebuild switch";
      nuf = "sudo nix flake update --flake /etc/nixos";
      ncg = "sudo nix-collect-garbage -d";
      co = "sudo -E hx /etc/nixos/configuration.nix";
      fl = "sudo -E hx /etc/nixos/flake.nix";
      ho = "sudo -E hx /etc/nixos/home.nix";
      sy = "cp /etc/nixos/{configuration.nix,flake.nix,flake.lock,home.nix} ~/nixos-dotfiles/ && cd ~/nixos-dotfiles && git add . && git commit -m 'ship it' && git push && cd - >/dev/null";
      von = "sudo wg-quick up protonvpn";
      voff = "sudo wg-quick down protonvpn";
      crack = "cd ~/handshakes && cat *.22000 > targets.hashes && hashcat -m 22000 -a 3 -w 3 targets.hashes '2741?d?d?d?d?d?d' && hashcat -m 22000 targets.hashes ~/rockyou.txt";
    };
  };

  users.defaultUserShell = pkgs.zsh;

  services.getty.autologinUser = "ice";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    memoryMax = 4294967296;
  };

  swapDevices = [];
 
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    zip
    microfetch
    prismlauncher
    aircrack-ng
    qrencode
    hcxtools
    hashcat
    epson-escpr
    steam
    nmap
    net-tools
    python3
    xdg-utils
    playerctl
    unzip
    bottom
    grim
    slurp
    wl-clipboard 
    wtype
    bibata-cursors
    autotiling-rs
    zsh
    localsend
    bluetui
    wiremix
    cliphist
    fzf
    wireguard-tools
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  system.stateVersion = "25.11";
}
