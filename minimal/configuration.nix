{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos";

  networking.wg-quick.interfaces = {
    protonvpn = {
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];
      privateKey = "oJ9JhQpUhezyp3caD1rmR578MgVH4I2ZwJOtpL2fYVY=";
      autostart = false;

      peers = [
        {
          publicKey = "Io8cLLfUyY9INwZ26X+thOzpMGRim0ek1VzZ19RpM2o=";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "185.252.220.146:51820";
        }
      ];
    };
  };

  environment.shellAliases = {
    von = "sudo systemctl start wg-quick-protonvpn";
    voff = "sudo systemctl stop wg-quick-protonvpn";
  };  

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

  documentation.nixos.enable = false;
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  nix.settings.auto-optimise-store = true;
  
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
      von = "sudo systemctl start wg-quick-protonvpn";
      voff = "sudo systemctl stop wg-quick-protonvpn";
    };
  };

  users.defaultUserShell = pkgs.zsh;

  services.getty.autologinUser = "ice";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    zip
    microfetch
    nmap
    net-tools
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
