{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
    inputs.helium.homeModules.default
  ];
  home.username = "kawa";
  home.homeDirectory = lib.mkForce "/home/kawa";
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    settings = {
      user.name = "kawa";
      user.email = "kawa0710@gmail.com";
    };
  };
  # programs.bash = {
  #   enable = true;
  #   shellAliases = {
    
  #   };
  # };
  # programs.fish = {
  #   enable = true;
  # };
  
  # xdg.configFile."niri/config.kdl".source = ./config.kdl;
  # xdg.configFile."niri/config.kdl".source = ../dotfiles/niri/config.kdl;
  programs.niri = {
    enable = true;
    config = ''
      ${builtins.readFile /home/kawa/dotfiles/niri/config.kdl}
      spawn-at-startup "noctalia"
      spawn-at-startup "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
    '';
  };


  programs.noctalia = {
    enable = true;
    settings = {
      
    };
  };

  programs.helium = {
    enable = true;
    # flags = [ "" ];
  };

  home.packages = with pkgs; [
    alacritty
    # xdg-utils
    # wl-clipboard
  ];

  programs.home-manager.enable = true;
}
