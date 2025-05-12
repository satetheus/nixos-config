{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "chris";
  home.homeDirectory = "/home/chris";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
    pkgs.btop
    pkgs.nodejs_22
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
        bashrcExtra = ". ~/dotfiles/homedir/.bashrc";
      };

      git = {
        enable = true;
        userName = "satetheus";
        userEmail = "personal@cwmccullough.com";
        aliases = {
            ctags = "!.git/hooks/ctags";
        };
        extraConfig = {
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
