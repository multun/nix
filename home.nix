{ config, pkgs, lib, ... }:
let nix_config = {
    allowUnfree = true;
    documentation.dev.enable = true;
    xdg.portal.enable = false;
    };
in
let mypkgs = import ./mypkgs.nix { inherit pkgs; };
    unstable = import <nixos-unstable> { config = nix_config; };
    binaryninja_python = (pkgs.python3.withPackages (ps: [
      # ps.flatbuffers
      # ps.pyside2
    ]));
    custom-steam = (unstable.steam
      # .override { extraPkgs = pkgs: [ pkgs.mono ] ;}
    );

    wayland-screenshot = (with pkgs; stdenv.mkDerivation {
      pname = "screenshot";
      version = "1.0";
      dontUnpack = true;
      installPhase = ''
      mkdir -p $out/{bin,share/applications}

      cat <<EOF > $out/bin/screenshot
      #!/bin/sh
      mkdir -p ~/screenshots
      exec ${grim}/bin/grim -t jpeg -g "\$(${slurp}/bin/slurp)" ~/screenshots/"\$(date +%Y-%m-%d_%H-%m-%s)".jpg
      EOF
      chmod +x $out/bin/screenshot

      cat <<EOF > $out/share/applications/screenshot.desktop
      [Desktop Entry]
      Name=Screenshot (Wayland)
      GenericName=Screenshot
      Comment=Take a screenshot, save it in ~/screenshots
      Exec=screenshot
      Terminal=false
      Type=Application
      Categories=Screenshot;
      EOF
      '';
    });

    # intellij isn't really ready for wayland, but _JAVA_AWT_WM_NONREPARENTING is required to make it kinda work
    idea-wayland = (with pkgs; stdenv.mkDerivation {
      name = "idea-wayland";
      # version = jetbrains.idea-community.version;
      buildInputs = [ jetbrains.idea-community ];
      src = ./.;
      installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/idea-wayland <<EOF
      #!/bin/sh
      export _JAVA_AWT_WM_NONREPARENTING=1
      exec ${jetbrains.idea-community}/bin/idea-community "\$@"
      EOF
      chmod +x $out/bin/idea-wayland

      mkdir -p $out/share/applications/
      out_desktop=$out/share/applications/idea-wayland.desktop
      sed 's/^Exec=idea-community/Exec=idea-wayland/g; s/^Name=IDEA/Name=IDEA (Wayland)/g' ${jetbrains.idea-community}/share/applications/idea-community.desktop > $out_desktop
      '';
    });

    chromium-wayland = (with pkgs; stdenv.mkDerivation {
      pname = "chromium-wayland";
      version = chromium.version;
      buildInputs = [ chromium ];
      src = ./.;
      installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/chromium-wayland <<EOF
      #!/bin/sh
      exec ${chromium}/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland "\$@"
      EOF
      chmod +x $out/bin/chromium-wayland

      mkdir -p $out/share/applications/
      out_desktop=$out/share/applications/chromium-browser-wayland.desktop
      sed 's/^Exec=chromium/Exec=chromium-wayland/g; s/^Name=Chromium/Name=Chromium (Wayland)/g' ${chromium}/share/applications/chromium-browser.desktop > $out_desktop
      '';
    });

    vscode-insider = (pkgs.vscode.override {isInsiders = true;}).overrideAttrs (oldAttrs: rec {
      src = (builtins.fetchTarball {
        url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
        sha256 = "0j2fffnghkp6amcsk74ws0p3168bbd1vk0ikay7lwpv62x78yn58";
      });
      version = "latest";
    });

    makeWaylandVSCode = ({ base, pname, binName }:
      unstable.stdenv.mkDerivation {
        inherit pname;  # must be kept this way for home manager to work
        version = base.version;
        buildInputs = [ base ];
        src = ./.;
        installPhase = ''
          mkdir -p $out/bin

          cat > $out/bin/${binName}-wayland <<EOF
          #!/bin/sh
          exec ${base}/bin/${binName} --enable-features=UseOzonePlatform --ozone-platform=wayland "\$@"
          EOF
          chmod +x $out/bin/${binName}-wayland

          mkdir -p $out/share/applications/
          in_desktop=${base}/share/applications/${binName}.desktop
          out_desktop=$out/share/applications/${binName}-wayland.desktop
          sed 's/^Exec=${binName}/Exec=${binName}-wayland/g; s/^Name=.*/Name=${binName} (Wayland)/g' $in_desktop > $out_desktop
      '';
      }
    );

    vscode-wayland = makeWaylandVSCode { base = vscode-insider; pname = "vscode-insiders"; binName = "code-insiders"; };
    codium-wayland = makeWaylandVSCode { base = pkgs.vscodium; pname = "vscodium"; binName = "codium"; };
in
{
  home.enableDebugInfo = true;

  home.activation.copyVSCodeConfig = {
    after = [ "linkGeneration" ];
    before = [];
    data = ''
      configPath=${config.home.homeDirectory}/.config/VSCodium/User/settings.json
      if [ -L "$configPath" ]; then
          realConfigPath=$(readlink -f "$configPath")
          rm -f "$configPath"
          cp "$realConfigPath" "$configPath"
      fi
    '';
  };

  programs.vscode = {
    enable = true;
    package = codium-wayland;
    userSettings = {
      "telemetry.enableCrashReporter" = false;
      "telemetry.enableTelemetry" = false;
      "update.channel" = "none";
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "workbench.colorTheme" = "Monokai";
      "mesonbuild.configureOnOpen" = true;
      "editor.fontSize" = 12;
      "editor.insertSpaces" = true;
      "editor.detectIndentation" = false;
      "editor.tabSize" = 4;
    };
    keybindings = [
      {
        key = "ctrl+alt+b";
        command = "workbench.action.toggleActivityBarVisibility";
      }
      {
        key = "ctrl+m";
        command = "workbench.action.toggleActivityBarVisibility";
      }
    ];
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      arrterian.nix-env-selector
      bbenoist.nix
      ms-python.python
      redhat.vscode-yaml
      redhat.java
      matklad.rust-analyzer
      tamasfe.even-better-toml
      ms-dotnettools.csharp
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "meson";
          publisher = "asabil";
          version = "1.3.0";
          sha256 = "sha256-QMp3dEFx6Mu5pgzklylW6b/ugYbtbT/qz8IeeuzPZeA=";
        };
        meta = with lib; {
          license = licenses.asl20;
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscode-openapi";
          publisher = "42Crunch";
          version = "4.13.0";
          sha256 = "sha256-BwVB5GXNFn95WbXhf9oMtqFkxHl4luYBTgesq6lZYtM=";
        };
        meta = with lib; {
          license = licenses.agpl3;
        };
      })
    ];
  };

  home.packages = with pkgs; [
    wineWowPackages.stable

    # rust stuff
    (let rust-config = {
           extensions = [
             "rustfmt"
             "clippy"
             "rls"
             "rust-src"
             "rust-analysis"
             "rust-analyzer"
           ];
         }; in
       (rust-bin.stable.latest.default.override rust-config))

    # proprietary stuff
    # nix-prefetch-url --type sha256 "file:///$(realpath BinaryNinja-personal.zip)"
    (pkgs.callPackage ./binaryninja {
      pname = "binaryninja";
      version = "3.2";
      src = requireFile {
        name = "BinaryNinja-personal.zip";
        url = "https://binary.ninja/recover/";
        sha256 = "086ivmb6bprvc48xfj6l5bwm4rvk8cczwmmdvnw7bxlzmqwm8wfg";
      };
    })

    # games
    custom-steam
    custom-steam.run
    prismlauncher  # minecraft

    # nix stuff
    nix-review
    nix-index
    nixpkgs-fmt

    # emacs
    aspell
    aspellDicts.fr
    aspellDicts.en-computers

    # sysadmin
    virtmanager
    debootstrap
    ansible
    ldns
    iptables
    docker-compose
    libcgroup # for cgcreate and friends

    # C dev tools
    (lib.lowPrio gcc)
    (lib.hiPrio clang)
    gnumake
    binutils
    gdb
    moreutils
    unrar

    # fonts
    fira
    fira-code
    fira-mono
    terminus_font
    font-awesome
    roboto
    lato
    roboto-mono
    powerline-fonts

    # window manager & friends / dotfiles stuff
    i3status-rust
    dejavu_fonts
    grml-zsh-config
    mypkgs.myxcwd
    numix-icon-theme
    hicolor-icon-theme

    # wayland stuff
    swaylock
    swayidle
    swaybg
    grim
    slurp
    wl-clipboard
    j4-dmenu-desktop
    bemenu
    wdisplays # arandr
    kanshi # autorandr
    wayland-screenshot

    # CLI utils
    exa
    ripgrep
    jq
    fzf
    file
    lf  # ranger style browser
    fd
    psmisc # for pstree, peekfd
    iftop
    bat
    tree
    inotify-tools
    man-pages
    zip
    unzip
    pv
    xorg.xkill
    xclip
    tokei

    # networking
    aria2
    rsync

    # desktop
    zathura
    okular
    unstable.firefox-wayland
    chromium-wayland
    android-file-transfer
    keepassxc
    usbutils

    # notifications
    libnotify

    # productivity
    unstable.super-productivity
    (unstable.callPackage ./furtherance.nix {})

    # audio / video
    mpv
    vlc
    quodlibet
    pavucontrol
    ffmpeg
    obs-studio

    # image processing
    gthumb
    gimp
    unstable.inkscape
    xournal

    # system config
    acpilight

    # keyboard stuff
    teensy-loader-cli

    # school
    geogebra

    # sncf
    sops
    gnupg
    jdk17
    idea-wayland
    dbeaver
    python3Packages.grip
  ];
  fonts.fontconfig.enable = true;

  nixpkgs.config = nix_config;

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

  programs.foot = {
    enable = true;
    # server.enable = true;
    settings = {
      main = {
        font = "Source Code Pro for Powerline:size=10";
        dpi-aware = "yes";
      };
      colors = {
        regular0 = "000000";  # black
        regular1 = "d54e53";  # red
        regular2 = "b9ca4a";  # green
        regular3 = "e6c547";  # yellow
        regular4 = "7aa6da";  # blue
        regular5 = "c397d8";  # magenta
        regular6 = "70c0ba";  # cyan
        regular7 = "eaeaea";  # white

        bright0 = "666666";  # black
        bright1 = "ff3334";  # red
        bright2 = "9ec400";  # green
        bright3 = "e7c547";  # yellow
        bright4 = "7aa6da";  # blue
        bright5 = "b77ee0";  # magenta
        bright6 = "54ced6";  # cyan
        bright7 = "ffffff";  # white
      };
    };
  };

  services.emacs = {
    enable = true;
    # the daemon needs to have the emacs load-path properly configured, so that
    # packages can be found by init scripts. as the load path is setup by a shell
    # wrapper at build time, the service has to use the properly wrapped program
    package = config.programs.emacs.finalPackage;
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs28;
    extraPackages = epkgs: (
      (with epkgs; [
        rust-mode
        writeroom-mode
        markdown-mode
        nix-mode
        magit
        multiple-cursors
        auto-complete
        csharp-mode
        yaml-mode
        rainbow-delimiters
        pyvenv
        company
        editorconfig
        which-key
        flycheck
        flycheck-pyflakes
      ])
    );
  };
  home.file.".emacs".source = "${mypkgs.my-emacs-config}/.emacs";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
    };
  };


  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
    config = null;
    extraConfig = builtins.readFile ./configs/sway;
  };

  home.file.".config/i3status-rust/config.toml".source = ./configs/i3status_rust.toml;
  home.file.".config/mpv/mpv.conf".source = ./configs/mpv.conf;
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

  services.gammastep = {
    enable = true;
    tray = true;
    provider = "manual";
    dawnTime = "6:00-7:45";
    duskTime = "18:35-22:15";
    temperature.night = 4500;
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = builtins.readFile ./configs/waybar.css;
    settings = [
      {
        layer = "top";
        position = "bottom";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "memory"
          "cpu"
          "temperature"
          "pulseaudio"
          "tray"
          "clock"
        ];

        modules = {
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };

          "sway/mode" = {
            format = "<span style=\"italic\">{}</span>";
          };

          "tray" = {
            icon-size = 21;
            spacing = 10;
          };

          "clock" = {
            tooltip-format = "<tt>{calendar}</tt>";
            format-alt = "{:%d/%m/%Y}";
          };

          "cpu" = {
            format = "{usage}% ";
          };

          "memory" = {
            format = "{}% ";
          };

          "pulseaudio" = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" ];
            };
            on-click = "pavucontrol";
          };

          "wlr/taskbar" = {
            on-click = "activate";
            on-click-middle = "close";
          };
        };
      }
    ];
  };

  programs.git = {
    enable = true;
    userEmail = "victor.collod@epita.fr";
    userName = "Victor \"multun\" Collod";
    ignores = [
      "*~"
      "\#*\#"
      ".\#*"
      ".idea"
      "*.svg"
      "__pycache__"
      "*.tar*"
    ];
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  gtk = {
    enable = true;
    theme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };
  };

  programs.home-manager = {
    enable = true;
  };

  home.stateVersion = "18.09";
}
