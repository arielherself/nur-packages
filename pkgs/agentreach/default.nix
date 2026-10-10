{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  # Platforms a target host may run; reach uploads the matching helper. These
  # are the same four the upstream release archives ship.
  helperPlatforms = [
    { goos = "linux"; goarch = "amd64"; }
    { goos = "linux"; goarch = "arm64"; }
    { goos = "darwin"; goarch = "amd64"; }
    { goos = "darwin"; goarch = "arm64"; }
  ];
in
buildGoModule (finalAttrs: {
  pname = "agentreach";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "bojieli";
    repo = "agentreach";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PL+YtRf+5L2j7WgpDNQn4DssPwGbA95iWKqNJ+U3FME=";
  };

  # go.mod has no requirements.
  vendorHash = null;

  subPackages = [ "cmd/reach" ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
    "-X main.buildCommit=v${finalAttrs.version}"
  ];

  # reach looks for reach-helper-<os>-<arch> beside its own (symlink-resolved)
  # executable, so the helpers live in libexec next to the real binary and
  # only `reach` itself goes on PATH.
  postBuild = lib.concatMapStrings
    ({ goos, goarch }: ''
      GOOS=${goos} GOARCH=${goarch} CGO_ENABLED=0 GOFLAGS=-trimpath \
        go build -ldflags "-s -w -X main.version=${finalAttrs.version}" \
        -o helpers/reach-helper-${goos}-${goarch} ./cmd/reach-helper
    '')
    helperPlatforms;

  # This one execs a `#!/usr/bin/env bash` script, which the sandbox lacks.
  checkFlags = [ "-skip=^TestShimPassthroughLeavesTheSeamArmed$" ];

  # Already -s -w; and a darwin strip must not touch the linux helpers.
  dontStrip = true;

  postInstall = ''
    mkdir -p $out/libexec/agentreach
    mv $out/bin/reach $out/libexec/agentreach/reach
    install -m 0755 helpers/* $out/libexec/agentreach/
    ln -s ../libexec/agentreach/reach $out/bin/reach
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/reach --version | grep -F ${finalAttrs.version}
    runHook postInstallCheck
  '';

  meta = {
    description = "Point your coding agent at any box you can SSH into, without installing the agent on the server";
    homepage = "https://github.com/bojieli/agentreach";
    changelog = "https://github.com/bojieli/agentreach/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "reach";
    platforms = lib.platforms.unix;
  };
})
