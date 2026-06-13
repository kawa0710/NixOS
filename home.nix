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
    userName = "kawa"; 
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

  programs.niri = {
    enable = true;
    settings = {
      environment = {
        "DISPLAY" = ":0";
      };

      input = {
        keyboard.xkb.layout = "us";
        touchpad.tap = true;
      };

      spawn-at-startup = [
        {
          command = [ "noctalia" ];
        }
        {
          command = [ "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent" ]; 
        }
      ];

      # binds = with config.lib.niri.actions; {
      #   "Mod+Return".action = spawn "alacritty";
      #  "Mod+Q".action = ckise-window;
      # };
    };
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
