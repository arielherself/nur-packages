# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/arielherself/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Attribute    | Description |
| ------------ | ----------- |
| `agentreach` | [AgentReach](https://github.com/arielherself/agentreach) (my fork of [bojieli/agentreach](https://github.com/bojieli/agentreach)) (`reach`): point your coding agent at any box you can SSH into, without installing the agent on the server. Also provides `reach-shell-prefix`, and ships the `reach-helper` builds for linux/darwin × amd64/arm64 targets. |
| `gameshelf`  | [gameshelf](https://github.com/arielherself/gameshelf): TUI game launcher for Windows games on Linux via umu-launcher and Proton. Falls back to nixpkgs' `umu-launcher` when no `umu-run` is on `PATH`. |
| `rplayhub`   | [rPlayHub](https://github.com/rPlayAI/rPlayHub) Linux client: iPhone screen mirroring and control over USB. `rplayhub` (GUI), `rplayhub-engine` (unprivileged engine), `rplayhub-fetch-ddi`. Built with upstream's RVRA-patched FFmpeg; needs `services.usbmuxd.enable = true` on NixOS. |

## Usage

With NUR set up:

```nix
environment.systemPackages = [ pkgs.nur.repos.arielherself.agentreach ];
```

Or straight from this repository:

```sh
nix run github:arielherself/nur-packages#agentreach -- --version
nix-build -A agentreach
```
