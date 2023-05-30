self: super: {
  waybar = (super.waybar.override { wireplumberSupport = false; })
	.overrideAttrs (finalAttrs: previousAttrs: rec {
	  version = "0.9.17";
    src = super.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = version;
      sha256 = "sha256-sdNenmzI/yvN9w4Z83ojDJi+2QBx2hxhJQCFkc5kCZw=";
    };
	  mesonFlags = previousAttrs.mesonFlags ++ [
	    "-Dmpris=disabled"
	  ];
	  mesonBuildType = "debug";

	  patches = [
	    (super.fetchpatch {
	      name = "desktop-app-info-create.patch";
	      url = "https://github.com/Alexays/Waybar/commit/df0fdce92b34406262ee522ad3910cefcc6ffd9e.patch";
	      hash = "sha256-i8Z/ii+YG4fyzh+JY2oNp3THlDWSgjZHaAAAxTwX/2o=";
	    })
	  ];
  });
}
