{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.default ];

  options.configFiles = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [ ];
    description = "Config files passed via `--config-file`.";
    example = lib.literalMd ''
      ```nix
      [ ./config ]
      ```
    '';
  };

  options.keybindings = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = ''
      Configure keybindings.

      See: https://ghostty.org/docs/config/keybind for more information.
    '';
    example = lib.literalMd ''
      ```nix
      [
         "ctrl+a>-=new_split:down"
         "ctrl+a>==new_split:right"
      ];
      ```
    '';
  };

  options.extraSettings = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.oneOf [
        lib.types.bool
        lib.types.float
        lib.types.int
        lib.types.str
        lib.types.path
      ]
    );
    default = { };
    description = ''
      > This can and will overwrite other options! For example providing
      > `keybind = ""` will remove all bindings provided by `options.keybindings`!

      Set arbitrary flags of ghostty. See
      https://github.com/ghostty-org/ghostty/blob/main/src/config/Config.zig
      for an exhaustive list of options.
    '';
    example = lib.literalMd ''
      ```nix
      {
        background-image = "~/Pictures/background.png";
        background-opacity = .5;
        focus-follows-mouse = true;
      };
      ```
    '';
  };

  config.package = pkgs.ghostty;

  config.flags = {
    "--config-file" = {
      ifs = null;
      data = config.configFiles;
    };
    "--keybind" = {
      ifs = null;
      data = config.keybindings;
    };
  }
  // lib.mapAttrs' (
    key: value: lib.nameValuePair "--${key}" (builtins.toString value)
  ) config.extraSettings;

  config.flagSeparator = "=";

  meta.maintainers = [ wlib.maintainers.elias-graf ];
}
