# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/arielherself/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Attribute    | Description |
| ------------ | ----------- |
| `agentreach` | [AgentReach](https://github.com/bojieli/agentreach) (`reach`): point your coding agent at any box you can SSH into, without installing the agent on the server. Ships the `reach-helper` builds for linux/darwin × amd64/arm64 targets. |

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
