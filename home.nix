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

  home.packages = with pkgs; [
    alacritty
    btop

    nemo
    nemo-fileroller
    file-roller # 這是實際處理壓縮檔的程式
    p7zip       # 確保系統裝有 7z 的支援庫
    
    nautilus # GNOME portal 依賴的檔案管理器
    # thunar
    kitty
    grc
    xwayland-satellite # xwayland support
    mousepad
    ksnip
    
    # inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide
    # inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # bottles # nixos 的不能建 bottle
    flatpak
    winboat
    libreoffice
    sourcegit
    zed-editor
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    vesktop
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "kawa";
      user.email = "kawa0710@gmail.com";
      http.sslVerify = false;
      credential.helper = "libsecret";
    };
  };
  
  # xdg.configFile."niri/config.kdl".source = ./config.kdl;
  # xdg.configFile."niri/config.kdl".source = ../dotfiles/niri/config.kdl;
  # xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink /home/kawa/nixos/niri/config.kdl;
  programs.niri = {
    enable = true;
    # config = ''
      # ${builtins.readFile ./niri/config.kdl}
      # spawn-at-startup "noctalia"
      # spawn-at-startup "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
    # '';
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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      # Manually packaging and enable a plugin
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
    ];
  };

  # programs.antigravity = {
  #   enable = true;
  #   profiles.default.extensions = with pkgs.vscode-extensions; [
  #     kenan-salar.calmppuccin-vscode
  #     yzhang.markdown-all-in-one
  #   ];
  # };

  programs.yazi = {
    enable = true;
    plugins = {
      inherit (pkgs.yaziPlugins) mount bookmarks;
    };
  };

  programs.home-manager.enable = true;

  
  services = {
  };


  i18n.inputMethod = {
    # NixOS 24.11 起的用法
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true;    # 吃下面的 settings，不用 user 的
      addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-configtool
        qt6Packages.fcitx5-chinese-addons
        fcitx5-chewing    # 新酷音
        fcitx5-table-extra
        fcitx5-fluent # 主题皮肤
        fcitx5-rime
        rime-data
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "canjie";
          "Groups/0/Items/2".Name = "rime";
          "Groups/0/Items/3".Name = "chewing";
        };
      };
    };
  };

 # 壓縮成 7z
  home.file.".local/share/nemo/actions/compress-7z.nemo_action" = {
    text = ''
      [Nemo Action]
      Name=Compress to .7z
      Exec=7z a "%F.7z" "%F"
      Selection=Any
      Extensions=any;
      Quote=double
    '';
  };

  # 解壓 7z
  home.file.".local/share/nemo/actions/extract-7z.nemo_action" = {
    text = ''
      [Nemo Action]
      Name=Extract here
      Exec=file-roller -h %F
      Selection=S
      Extensions=zip;7z;ar;cbz;cpio;exe;iso;jar;tar;7z;tar.Z;tar.bz2;tar.gz;tar.lz;tar.lzma;tar.xz;
      Icon-Name=application-x-7z-compressed
      Quote=double
    '';
  };
}
