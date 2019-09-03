{ pkgs, lib, ... }:
let mypkgs = import ./mypkgs.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # nix stuff
    nix-review

    # acu stuff
    fira
    fira-code
    fira-mono
    aspell
    aspellDicts.fr
    aspellDicts.en-computers
    texlive.combined.scheme-full

    # sysadmin
    virtmanager
    debootstrap
    ansible

    # dev tools
    (lib.lowPrio clang)
    (lib.hiPrio gcc)
    gnumake
    python3Packages.grip
    clang-tools
    jq
    binutils
    gdb

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

    # desktop
    zathura
    firefox
    android-file-transfer
    keepassxc

    # audio / video
    mpv
    pavucontrol
    pulseeffects

    # image processing
    scrot
    gthumb
    gimp
    feh

    # system config
    arandr
    acpilight
  ];
  fonts.fontconfig.enable = true;

  nixpkgs.config = {
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
    extraPackages = epkgs: [
      epkgs.writeroom-mode
      epkgs.markdown-mode
      epkgs.nix-mode
      epkgs.magit
      epkgs.flycheck-pyflakes
      epkgs.multiple-cursors
      epkgs.auto-complete
      epkgs.csharp-mode
      epkgs.yaml-mode
      epkgs.flycheck-irony
      epkgs.irony
      epkgs.flycheck
      epkgs.clang-format
      epkgs.rainbow-delimiters
      epkgs.pyvenv
      epkgs.company-irony
    ];

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
  home.file.".gdbinit".source = mypkgs.my-gdbinit;
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
  };
}
