# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  nix.extraOptions = "experimental-features = nix-command flakes";
  imports = [
      ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # configuration for dual monitors
  services.xserver.videoDrivers = [ "nvidia" ];
  #services.xserver.displayManager.setupCommands = ''
        #LEFT='HDMI-0'
        #RIGHT='DP-3'
        #${pkgs.xorg.xrandr}/bin/xrandr --output $RIGHT --mode 1920x1080 --preferred --output $LEFT --mode 1920x1080 --left-of $RIGHT
  #'';

  hardware.nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = false;
          open = true;
          nvidiaSettings = true;
          #package =  config.boot.kernelPackages.nvidiaPackages.stable;
          package =  config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chris = {
    isNormalUser = true;
    description = "Chris McCullough";
    extraGroups = [ "networkmanager" "wheel" "openrazer" "plugdev" "audio"];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    brave
    pkgs.discord-ptb
    git
    gh
    obsidian
    obs-studio
    fzf
    fd
    pkgs.home-manager
    ripgrep

    hyprlock
    wl-clipboard # for neovim copy/paste

    openrazer-daemon # for openrazer headphones
    polychromatic # for openrazer headphones

    wofi

    musescore

    python310
    libssh2
    glibc
    steam-run
    (prismlauncher.override {
        jdks = [
            graalvm-ce
            zulu8
            zulu17
            zulu
            pkgs.jdk21
            pkgs.jdk17
            pkgs.jdk8
    ];
    })

    cudaPackages.cudatoolkit
    pinentry
    spotify
    spotifyd
    vlc
    libvlc
    wezterm
    kitty
    wineWowPackages.stable
    winetricks
    zellij
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # necessary for obsidian
  ];

  services.hypridle.enable = true;
  security.pam.services.hyprlock = {};

  programs.hyprland = {
      enable = true;
  };

  # pinentry configuration for gpg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # steam configuration
  #programs.steam.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    #localNetworkGameTransfers.openFirewall = true;
  };

  # discord configuration
  nixpkgs.overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz; });})];

  # spotify port allowance
  networking.firewall.allowedTCPPorts = [ 137 138 139 445 57621 ]; 
  networking.firewall.allowedUDPPorts = [ 5353 ]; 

  services.ollama = {
      enable = true;
      acceleration = "cuda";
  };

  # automatic updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "monthly";

  # automatic garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 35d";
  nix.settings.auto-optimise-store = true;

  # adjust download settings
  nix.settings.download-buffer-size = 500000000; #500MB

  # setup samba for vlc sharing
  services.samba = {
        package = pkgs.samba4Full;
        # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
        # Required for samba to register mDNS records for auto discovery 
        # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
        enable = true;
        openFirewall = true;
        shares.testshare = {
          path = "/mnt/Shares/Public";
          writable = "true";
          comment = "Hello World!";
        };
  };
  services.avahi = {
        publish.enable = true;
        publish.userServices = true;
        # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
        enable = true;
        openFirewall = true;
  };
  services.samba-wsdd = {
      # This enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
        enable = true;
        openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
