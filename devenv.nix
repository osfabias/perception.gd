{
  pkgs,
  ...
}:
{
  packages = with pkgs; [
    godot_4_7
    blender
    gdscript-formatter
  ];

  # Print the stable path to the Blender executable and enable the Git hooks
  enterShell = ''
    echo "Blender executable path: $DEVENV_ROOT/.devenv/profile/bin/blender"

    if [ -z "$(git config --local core.hooksPath)" ]; then
      git config --local core.hooksPath .githooks
    fi
  '';
}
