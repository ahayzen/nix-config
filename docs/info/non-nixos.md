<!--
SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>

SPDX-License-Identifier: MPL-2.0
-->

# Using on non-NixOS

Install Nix using [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) as this works on Fedora Silverblue too.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

## Home-manager

Initial install

```bash
nix run home-manager/release-24.11 -- init
nix run home-manager/release-24.11 -- switch -b backup --flake .#home-name
```

To update

```
home-manager switch -b backup --flake .#home-name
```

## NixGL

Integration with the hosts GPU drivers needs to be setup otherwise
errors such as `NotSupported("provided display handle is not supported")`
can occur when running `alacritty` or other GPU apps.

```bash
nix profile install --override-input nixpkgs nixpkgs/nixos-24.11 github:nix-community/nixGL --impure
```

Then run `nixGL <command>` to wrap the command and setup GPU drivers.

Copying the desktop file and injecting in nixGL for convenience.

```bash
cp ~/.nix-profile/share/applications/Alacritty.desktop ~/.local/share/applications/Alacritty.desktop
chmod 755 ~/.local/share/applications/Alacritty.desktop
sed -E -i "s/^Exec=alacritty/Exec=nixGL alacritty/g" ~/.local/share/applications/Alacritty.desktop
```

## XDG

Integration with the host can be improved by using `targets.genericLinux.enable = true;`

If this is not enabled then add the following to `~/.profile`.

```bash
. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
```
