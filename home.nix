{ pkgs, lib, ... }:
let mypkgs = import ./mypkgs.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # rust stuff
    rustc
    cargo
    rustfmt

    # nix stuff
    nix-review
    nixpkgs-fmt

    # acu stuff
    fira
    fira-code
    fira-mono
    aspell
    aspellDicts.fr
    aspellDicts.en-computers
    texlive.combined.scheme-full
    vim
    slrn
    cmake
    ltrace
    lldb
    rr
    uftrace
    graphviz
    imagemagick
    sourcetrail

    # sysadmin
    virtmanager
    debootstrap
    ansible
    ldns
    iptables
    docker-compose
    libcgroup # for cgcreate and friends

    # dev tools
    (lib.lowPrio clang)
    (lib.hiPrio gcc)
    gnumake
    python3Packages.grip
    clang-tools
    jq
    binutils
    gdb
    moreutils
    unrar

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

    # audio / video
    mpv
    vlc
    audacity
    pavucontrol
    ffmpeg
    vokoscreen # screen recorder

    # image processing
    scrot
    gthumb
    gimp
    feh
    inkscape

    # 3d graphics
    apitrace
    blender
    renderdoc
    meshlab

    # system config
    arandr
    acpilight

    # school
    geogebra
  ];
  fonts.fontconfig.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    documentation.dev.enable = true;
    xdg.portal.enable = false;
  };

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
        flycheck-irony
        irony
        flycheck
        clang-format
        rainbow-delimiters
        pyvenv
        company
        company-irony
        editorconfig
        which-key
      ])
    );

    overrides = (self: super: {
      irony = super.irony.overrideAttrs(old: {
        version = builtins.head (builtins.splitVersion old.version);
        preBuild = ''
          make
          make install
        '';

        postInstall = ''
          mkdir -p $out
          rm -rf $out/share/emacs/site-lisp/elpa/*/server
        '';
        packageRequires = [ ];
        meta = old.meta // {
          broken = false;
        };
      });
    });
  };

  home.file.".emacs".source = "${mypkgs.my-emacs-config}/.emacs";
  home.file.".config/i3/config".source = ./configs/i3config;
  home.file.".config/i3status_rust.toml".source = ./configs/i3status_rust.toml;
  home.file.".config/alacritty/alacritty.yml".source = ./configs/alacritty.yml;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.redshift = {
    enable = true;
    latitude = "47";
    longitude = "2";
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
}
