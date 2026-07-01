{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
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

    nemo-with-extensions
    file-roller # 後台實際執行壓縮/解壓縮的引擎
    p7zip # 確保系統裝有 7z 的支援庫
    unzip # 確保 zip 解壓支援
    # thunar

    # 確保有 Qt 的輸入法內聯組件
    libsForQt5.fcitx5-qt

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
    podman-compose

    libreoffice
    sourcegit
    zed-editor
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    vesktop
    remmina
  ];

  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        line-number = "relative";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  home.sessionVariables = {
    # 告訴 Nemo 去哪裡尋找右鍵擴充套件（NixOS 系統與使用者環境路徑）
    NEMO_EXTENSION_DIR = "${pkgs.nemo-fileroller}/lib/nemo/extensions-3.0";

    # 讓 Gtk 應用程式（如 Chrome, Firefox）支援 Fcitx5
    GTK_IM_MODULE = "fcitx";

    # 讓 Qt 應用程式（如 Telegram, KeepassXC）支援 Fcitx5
    QT_IM_MODULE = "fcitx";

    # 傳統 X11 應用程式支援
    XMODIFIERS = "@im=fcitx";

    # Wayland 特定的輸入法協議支援
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus"; # 部分新版 GLFW 應用（如 Alacritty）透過 ibus 協議接 Fcitx5
  };

  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo"; # 確保指向包裝版
  };

  xdg.desktopEntries = {
    # 使用 "org.ksnip.ksnip" 作為 Key，確保生成的檔名完全一致
    "org.ksnip.ksnip" = {
      name = "ksnip";
      genericName = "ksnip Screenshot Tool";
      comment = "Cross-platform screenshot tool that provides many annotation features for your screenshots.";

      # 修正主程式的核心路徑
      exec = "${pkgs.ksnip}/bin/ksnip %F";
      icon = "ksnip";
      terminal = false;
      startupNotify = false;
      type = "Application";
      categories = [ "Utility" ];
      mimeType = [
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/jpg"
        "image/png"
      ];

      # 1. 還原 [Desktop Action ...] 的右鍵選單功能，並將執行路徑一併修正
      actions = {
        Area = {
          name = "Capture a rectangular area";
          exec = "${pkgs.ksnip}/bin/ksnip -r -c";
          icon = "ksnip";
        };
        LastArea = {
          name = "Capture last selected rectangular area";
          exec = "${pkgs.ksnip}/bin/ksnip -l -c";
          icon = "ksnip";
        };
        FullScreen = {
          name = "Capture a fullscreen";
          exec = "${pkgs.ksnip}/bin/ksnip -m -c";
          icon = "ksnip";
        };
        Window = {
          name = "Capture the focused window";
          exec = "${pkgs.ksnip}/bin/ksnip -a -c";
          icon = "ksnip";
        };
      };

      # 2. 透過 settings 補上原設定中非標準的常規欄位與多國語言
      settings = {
        "X-KDE-DBUS-Restricted-Interfaces" = "org.kde.kwin.Screenshot,org.kde.KWin.ScreenShot2";
        # "GenericName[ru]" = "Создание снимков экрана";
        # "Comment[ru]" = "Кросс-платформенный инструмент для создания снимков экрана, который предоставляет множество функций их аннотирования.";
        # "Comment[pt_BR]" = "Ferramenta de captura de tela de Cross-plataforma que fornece...</string>";

        # 同步補上 Actions 的多國語言翻譯
        # "Desktop Action Area/Name[ru]" = "Снимок выделенной области";
        # "Desktop Action LastArea/Name[ru]" = "Снимок последней области";
        # "Desktop Action FullScreen/Name[ru]" = "Снимок всего экрана";
        # "Desktop Action Window/Name[ru]" = "Снимок активного экрана";
      };
    };
  };

  # 讓 systemd 知道用戶端的應用程式路徑
  systemd.user.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:${pkgs.ksnip}/share";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # 將所有資料夾的開啟方式預設為 Nemo
      "inode/directory" = [ "nemo.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
    };
  };

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
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink /home/kawa/nixos/niri/config.kdl;
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
      set -e DBUS_SESSION_BUS_ADDRESS
    '';
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
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

  i18n.inputMethod = {
    # NixOS 24.11 起的用法
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true; # 吃下面的 settings，不用 user 的
      addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-configtool
        qt6Packages.fcitx5-chinese-addons
        fcitx5-chewing # 新酷音
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
  # home.file.".local/share/nemo/actions/compress-7z.nemo_action" = {
  #   text = ''
  #     [Nemo Action]
  #     Name=Compress to .7z
  #     Exec=7z a "%F.7z" "%F"
  #     Selection=Any
  #     Extensions=any;
  #     Quote=double
  #   '';
  # };

  # 解壓 7z
  # home.file.".local/share/nemo/actions/extract-7z.nemo_action" = {
  #   text = ''
  #     [Nemo Action]
  #     Name=Extract here
  #     Exec=file-roller -h %F
  #     Selection=S
  #     Extensions=zip;7z;ar;cbz;cpio;exe;iso;jar;tar;7z;tar.Z;tar.bz2;tar.gz;tar.lz;tar.lzma;tar.xz;
  #     Icon-Name=application-x-7z-compressed
  #     Quote=double
  #   '';
  # };
}
