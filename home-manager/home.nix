{ config, pkgs, ... }:

{
  # this should not be required, but the is a long-standing bug (3+ years!)
  # that causes the below line to be necessary in stand-alone flake configs
  # for home-manager
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  home.username = "chris";
  home.homeDirectory = "/home/chris";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
    pkgs.btop
    pkgs.obsidian
    pkgs.obs-studio
    pkgs.musescore
    pkgs.steam-run
    pkgs.vlc
    pkgs.zellij
    pkgs.gh
    pkgs.starship
    pkgs.calibre
  ];

  # required for hyprland
  programs.kitty.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/chris/dotfiles/neovim";
        recursive = true;
    };
  };

  programs = {
      bash = {
        enable = true;
        profileExtra = "eval `keychain --nogui --eval --agents ssh gh`";
        bashrcExtra = ". ~/dotfiles/homedir/.bashrc";
        historyFileSize = -1;
        historySize = -1;
      };

      git = {
        enable = true;
        settings = {
            user.name = "satetheus";
            user.email = "personal@cwmccullough.com";
            alias = {
                ctags = "!.git/hooks/ctags";
            };
            commit.gpgsign = true;
            tag.gpgsign = true;
            user.signingkey = "CA7F4107215BD7FD";
            init.defaultbranch = "main";
            init.templatedir = "~/.git_template";
        };
      };

      # Let Home Manager install and manage itself.
      home-manager.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

}
