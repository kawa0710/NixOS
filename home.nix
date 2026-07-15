{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    fnm
    sourcegit
    dbeaver-bin
    inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default
    grim
    trayscale
    rustdesk-flutter

    alacritty
    btop

    file-roller # 後台實際執行壓縮/解壓縮的引擎
    p7zip # 確保系統裝有 7z 的支援庫
    unzip # 確保 zip 解壓支援

    # Thunar 主程式
    thunar
    # 常用外掛
    thunar-archive-plugin # 解壓縮選單支援
    thunar-volman # 自動掛載裝置支援

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
    onlyoffice-desktopeditors
    sourcegit
    zed-editor
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    vesktop
    remmina
    bruno
    jq
  ];

  imports = [
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
    inputs.helium.homeModules.default
  ];
  home.username = "kawa";
  home.homeDirectory = lib.mkForce "/home/kawa";
  home.stateVersion = "26.05";

  # 啟用 Syncthing 服務
  services.syncthing = {
    enable = true;

    # 強制使用 Home Manager 的設定覆蓋 GUI 手動修改的內容
    overrideFolders = true;
    overrideDevices = true;

    # 定義遠端裝置
    settings.devices = {
      "Kawa2021" = {
        id = "Q4W4WEM-GAUZKXF-EQUNTBG-EKFL6WY-QKZK43P-6XTOZNE-KSICVNU-EAVYVAM"; # 你的遠端裝置 ID
        name = "Kawa2021"; # 可選：方便識別的自訂名稱
      };
    };

    # 定義同步資料夾
    settings.folders = {
      "oz3je-t5qbk" = {
        # 設定要同步的本機路徑
        path = "/run/media/kawa/Transcend/工作";

        # 指定要同步給哪些裝置（對應上面 devices 設定的名稱）
        devices = [ "Kawa2021" ];

        # 設定同步類型為「僅傳送」(Send Only)
        type = "sendonly";

        # 自訂在 Syncthing GUI 上顯示的資料夾名稱
        label = "工作";
      };
    };
  };

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

  # nixos 安裝的 ksnip.desktop 路徑有錯(26.05/26.11)
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
      # 將所有資料夾的開啟方式預設為 thunar
      "inode/directory" = [ "thunar.desktop" ];
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
    flags = [ "--password-store=basic" ];
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "ls -lah --color=always --group-directories-first";
      grep = "grep --color=auto";
    };
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -e DBUS_SESSION_BUS_ADDRESS
      fnm env --use-on-cd --shell fish | source
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

}
