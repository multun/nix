{ pkgs, ... }:
let mypkgs = import ./mypkgs.nix { inherit pkgs; };
in
{
  home.packages = [
    pkgs.font-awesome-ttf
    pkgs.htop
    pkgs.fortune
    pkgs.clang-tools
    pkgs.alacritty
    pkgs.terminus_font
    pkgs.font-awesome
    pkgs.powerline-fonts
    pkgs.i3status-rust
    pkgs.dejavu_fonts
    pkgs.keepassxc
    pkgs.rsync
    pkgs.notmuch
    pkgs.astroid
    pkgs.iftop
    pkgs.bat
    pkgs.grml-zsh-config
    pkgs.android-file-transfer
    pkgs.acpilight
    pkgs.gthumb
    pkgs.gimp
    pkgs.scrot
    mypkgs.myxcwd
  ];
  fonts.fontconfig.enable = true;

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
    ];
  };
  home.file.".emacs".source = "${mypkgs.my-emacs-config}/.emacs";

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