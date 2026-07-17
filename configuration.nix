# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    openfortivpn
    fastfetch

    wget
    curl
    fzf
    ripgrep
    fd
    bat
    # --- niri setup begin ---
    tuigreet
    lxqt.lxqt-policykit
    # --- niri setup begin ---

    libsecret
  ];

  environment.etc."openfortivpn/config" = {
    text = ''
      host = 59.120.82.208
      port = 443
      username = kawa.cheng
      trusted-cert = f9434e90d10d6ef46cfa9b9fc9b88a48ff29f118e7bb037cd0920ce0dbf5a5f8
    '';
  };

  # 為了啟用fnm
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    icu
    # 如果之後有遇到其他 LSP 報錯，也可以加在這裡，例如：
    # zlib
    # openssl
  ];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      # 當插著電源時
      charger = {
        governor = "performance";
        turbo = "always"; # 強制開啟 Turbo 模式
      };

      # 當使用電池時
      battery = {
        governor = "powersave";
        turbo = "never";
      };
    };
  };

  # 避免其他電源管理服務衝突（NixOS 預設的 power-profiles-daemon 可能會與 auto-cpufreq 衝突）
  services.power-profiles-daemon.enable = false;

  services.tailscale.enable = true;
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # 3. Optimization: Prevent systemd from waiting for network online
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  # 啟用 input-remapper 服務（這會自動處理權限與後台守護進程）
  services.input-remapper.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly"; # Or use a specific time like "03:15"
    options = "--delete-older-than 30d";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-cce3f8be-1366-44f4-82ea-242cec24b6b6".device =
    "/dev/disk/by-uuid/cce3f8be-1366-44f4-82ea-242cec24b6b6";
  networking.hostName = "KawaNixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable bluetooth, power and battery management
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true;
  # services.power-profiles.daemon.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_TW.UTF-8";
    LC_IDENTIFICATION = "zh_TW.UTF-8";
    LC_MEASUREMENT = "zh_TW.UTF-8";
    LC_MONETARY = "zh_TW.UTF-8";
    LC_NAME = "zh_TW.UTF-8";
    LC_NUMERIC = "zh_TW.UTF-8";
    LC_PAPER = "zh_TW.UTF-8";
    LC_TELEPHONE = "zh_TW.UTF-8";
    LC_TIME = "zh_TW.UTF-8";
  };

  # === NVIDIA CONFIGURATION FOR LAPTOP ===
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = true; # The stable solution
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  # === END OF NVIDIA CONFIGURATION ===

  # 必須在系統層級啟用 flatpak 服務（這會自動處理大部分的路徑與權限）
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    # windowManager.niri.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # 新增podman
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # Creates a 'docker' alias so WinBoat can find necessary commands
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # 啟用核心非特權名稱空間 for podman
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

  # Define a user account.
  users.users."kawa" = {
    isNormalUser = true;
    description = "Kawa";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "podman"
      "docker"
      "input"
      "uinput"
    ];
    # packages = with pkgs; [];
    # 若要使用免 Root (Rootless) 模式，請務必配置 subUid/subGid 區間
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.bash = {
    enable = true;
    #  Setting fish as default shell
    interactiveShellInit = ''
      # "check if parent process is not fish" && "make nested shells work properly"
      if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
          # set $SHELL for better integration with programs like nix shell, tmux, etc.
          SHELL=${pkgs.fish}/bin/fish exec fish
      fi
    '';
  };
  # programs.fish = {
  #   enable = true;
  # };

  # --- niri setup begin ---
  # Sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  programs.dconf.enable = true; # Settings management
  programs.xfconf.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'niri --session'";
        user = "greeter";
      };
    };
  };

  systemd.user.services.niri.enableDefaultPath = false;
  services.gvfs.enable = true; # 檔案管理 掛載 USB 或網路硬碟
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  services.tumbler.enable = true; # Thumbnail support for images

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.niri.enable = true;

  # 強迫 niri-session 去拉起圖形會話
  systemd.user.targets.niri-session = {
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };

  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common.default = [
      "gtk"
      "gnome"
    ];
    # Niri 在底層實作了 GNOME 的私有協定。因此，Niri 的螢幕分享（ScreenCast）和截圖（Screenshot），綁定 xdg-desktop-portal-gnome
    config.niri = {
      default = lib.mkDefault [
        "gtk"
        "gnome"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [
        # "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = [
        "gnome"
        # "gtk"
      ];
      "org.freedesktop.impl.portal.Screenshot" = [
        "gnome"
        # "gtk"
      ];
    };
  };

  # --- niri setup end ---

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };

  services.dbus.enable = true;

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
