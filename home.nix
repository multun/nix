{ pkgs, lib, ... }:
let nix_config = {
    allowUnfree = true;
    documentation.dev.enable = true;
    xdg.portal.enable = false;
    };
in
let mypkgs = import ./mypkgs.nix { inherit pkgs; };
    unstable = import <nixos-unstable> { config = nix_config; };
    binaryninja_python = (unstable.python3.withPackages (ps: [
      ps.flatbuffers
      ps.pyside2
    ]));
in
{
  home.enableDebugInfo = true;

  home.packages = with pkgs; [
    wineWowPackages.stable

    vscode
    mypkgs.mdbg

    # rust stuff
    (rust-bin.stable.latest.default.override {
      extensions = [
        "rustfmt"
        "clippy"

        # rust language server stuff
        "rls"
        "rust-src"
        "rust-analysis"
      ];
    })

    # LSE stuff
    ghidra-bin
    radare2
    radare2-cutter
    nasm

    unstable.python38Packages.binwalk-full

    # proprietary stuff
    # nix-prefetch-url --type sha256 "file:///$(realpath BinaryNinja-personal.zip)"
    (unstable.callPackage ./binaryninja.nix {
      pname = "binaryninja";
      version = "2.4";
      src = requireFile {
        name = "BinaryNinja-personal.zip";
        url = "https://binary.ninja/recover/";
        sha256 = "0v14mwryljhl6a0ysfp9wrbv7jh7w2i2cd1gn7yn4l9fmxqy66dm";
      };
    })

    # # nix-prefetch-url --type sha256 "file:///$(realpath BinaryNinja-personal-dev.zip)"
    # (unstable.callPackage ./binaryninja.nix {
    #   pname = "binaryninja-dev";
    #   version = "2.3.2691-dev";
    #   src = requireFile {
    #     name = "BinaryNinja-personal-dev.zip";
    #     url = "https://binary.ninja/recover/";
    #     sha256 = "0di93l0fri1grhv0aph6j97dlxhgsbmmn8rfrzv3zq35j2wplvmq";
    #   };
    # })

    steam

    # nix stuff
    nix-review
    nix-index
    nixpkgs-fmt
    steam-run

    # acu stuff
    fira
    fira-code
    fira-mono
    aspell
    aspellDicts.fr
    aspellDicts.en-computers
    # texlive.combined.scheme-full
    vim
    slrn
    cmake
    ltrace
    lldb
    rr
    uftrace
    graphviz
    imagemagick
    # sourcetrail

    # sysadmin
    virtmanager
    debootstrap
    ansible
    ldns
    iptables
    docker-compose
    libcgroup # for cgcreate and friends

    # dev tools
    (lib.lowPrio gcc)
    (lib.hiPrio clang)
    gnumake
    python3Packages.grip
    clang-tools
    jq
    binutils
    gdb
    moreutils
    unrar
    valgrind
    ninja
    meson
    readline

    # window manager & friends / dotfiles stuff
    alacritty
    terminus_font
    font-awesome-ttf
    font-awesome
    powerline-fonts
    i3status-rust
    dejavu_fonts
    grml-zsh-config
    mypkgs.myxcwd
    numix-icon-theme
    hicolor-icon-theme

    # CLI utils
    exa
    ripgrep
    fzf
    file
    lf
    fd
    htop
    psmisc
    fortune
    iftop
    bat
    tree
    inotify-tools
    manpages
    zip
    unzip
    pv
    xorg.xkill
    xclip
    tokei

    # emails
    isync   # receive
    notmuch # index and search
    astroid # view
    msmtp   # send

    # networking
    wpa_supplicant_gui
    aircrack-ng
    aria2
    rsync
    nmap

    # desktop
    zathura
    okular
    evince
    firefox
    chromium
    android-file-transfer
    keepassxc
    screenkey
    libreoffice-fresh
    simple-scan
    usbutils

    # notifications
    libnotify

    # productivity
    unstable.super-productivity

    # social
    unstable.ripcord

    # audio / video
    mpv
    vlc
    audacity
    pavucontrol
    ffmpeg
    vokoscreen # screen recorder
    obs-studio
    obs-v4l2sink

    # image processing
    scrot
    gthumb
    gimp
    feh
    inkscape
    xournal

    # 3d graphics
    apitrace
    blender
    renderdoc
    meshlab

    # system config
    arandr
    acpilight

    # keyboard stuff
    teensy-loader-cli

    # school
    geogebra

    # sncf
    gradle_jdk11
    jdk11
    jetbrains.idea-community
  ];
  fonts.fontconfig.enable = true;

  nixpkgs.config = nix_config;

  # services.kdeconnect.enable = true;

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    history.extended = true;
    initExtra = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      setopt extendedglob
      source ${./configs/aliases.sh}
      bindkey '^R' history-incremental-pattern-search-backward
      bindkey '^F' history-incremental-pattern-search-forward
    '';
  };


  # https://github.com/Sarcasm/irony-mode/issues/469
  services.emacs.enable = true;
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: (
      (with epkgs; [
        rust-mode
        writeroom-mode
        markdown-mode
        nix-mode
        magit
        flycheck-pyflakes
        multiple-cursors
        auto-complete
        csharp-mode
        yaml-mode
        # flycheck-irony
        # irony
        flycheck
        # clang-format
        rainbow-delimiters
        pyvenv
        company
        # company-irony
        editorconfig
        which-key
      ])
    );
  };

  home.file.".emacs".source = "${mypkgs.my-emacs-config}/.emacs";
  home.file.".config/i3/config".source = ./configs/i3config;
  home.file.".config/i3status-rust/config.toml".source = ./configs/i3status_rust.toml;
  home.file.".config/alacritty/alacritty.yml".source = ./configs/alacritty.yml;
  home.file.".config/mpv/mpv.conf".source = ./configs/mpv.conf;
  home.file.".slrnrc".source = ./slrnrc;
  home.file.".signature".source = ./signature;
  home.file.".binaryninja/settings.json".source = pkgs.writeText "binaryninja-settings" (builtins.toJSON ({
      "analysis.limits.cacheSize" = 64;
      "analysis.types.TemplateSimplifier" = true;
      "python.interpreter" = "${binaryninja_python}/lib/libpython3.so";
      "python.virtualenv" = "${binaryninja_python}/${binaryninja_python.sitePackages}";
      "triage.analysisMode" = "full";
      "ui.debugMode" = true;
      "ui.font.style" = "Regular";
      "ui.style.hlil.scoping" = "braces";
      "ui.view.graph.preferred" = true;
      "updates.activeContent" = false;
  }));
  home.file.".config/obs-studio/plugins/v4l2sink".source =
    "${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink";

  # dunst is a notification deamon
  services.dunst = {
    enable = true;
    settings = rec {
      global = {
        follow = "keyboard";
        markup = "none";
        format = ''
          <big><b>%s</b></big>
          %b'';
        sort = false;
        alignment = "left";
        bounce_freq = 0;
        word_wrap = true;
        ignore_newline = false;
        geometry = "450x100-15+49";
        transparency = 10;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 20;
        line_height = 3;
        separator_color = "frame";
        frame_width = 2;
        frame_color = "#EC5F67";
      };

      urgency_normal = {
        foreground = "#CDD3DE";
        background = "#101010";
        timeout = 6;
      };
      urgency_low = urgency_normal;
      urgency_critical = urgency_normal;
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.redshift = {
    enable = true;
    tray = true;
    latitude = "49";
    longitude = "2";
    temperature = {
      day = 5500;
      night = 2600;
    };
  };

  programs.home-manager = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userEmail = "victor.collod@epita.fr";
    userName = "Victor \"multun\" Collod";
    ignores = [ "*~" "\#*\#" ".\#*" ];
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };
}
