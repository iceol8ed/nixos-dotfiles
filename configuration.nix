{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  networking.firewall = {
  allowedTCPPorts = [ 53317 ];
  allowedUDPPorts = [ 53317 ];
  };

  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  system.autoUpgrade = {
    enable = true;

    # since your flake is located at /etc/nixos:
    flake = "/etc/nixos";

    # timer schedule: weekly
    dates = "weekly";

    # optional quality-of-life settings:
    randomizedDelaySec = "30min";
    operation = "switch";
    allowReboot = false;

    # rebuild flags
    flags = [ "-L" ];
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "render" ]; # Enable ‘sudo’ for the user.
  };
  
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword=false;

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
    export PROMPT='%1~ %# '
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[path]=none
    ZSH_HIGHLIGHT_STYLES[path_prefix]=none
    ZSH_HIGHLIGHT_STYLES[path_separator]=none
    ZSH_HIGHLIGHT_STYLES[precommand]=none
    '';
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nos = "sudo nixos-rebuild switch";
      nuf = "sudo nix flake update --flake /etc/nixos";
      ncg = "sudo nix-collect-garbage -d";
      co = "sudo hx /etc/nixos/configuration.nix";
      fl = "sudo hx /etc/nixos/flake.nix";
      ho = "sudo hx /etc/nixos/home.nix";
      von = "sudo wg-quick up protonvpn";
      voff = "sudo wg-quick down protonvpn";
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
    fastfetch
    unzip
    gcc
    btop
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
    ungoogled-chromium
    wireguard-tools
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
  ];
  fonts.fontconfig = {
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
  system.stateVersion = "25.11"; # Did you read the comment?

}
