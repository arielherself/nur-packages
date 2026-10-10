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

  # internal/reach/types.go. The helper must report exactly this, or reach's
  # post-upload selftest sees a mismatch and reinstalls it on every connect.
  reachVersion = "0.8.0";
  rev = "98d74ac166712fab869601fd1f43077d6c7b8d84";
in
buildGoModule (finalAttrs: {
  pname = "agentreach";
  version = "${reachVersion}-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "arielherself";
    repo = "agentreach";
    inherit rev;
    hash = "sha256-C1krYu7rSggXBFU3LiYdL3Mw4pucwscwYd/T7+GEuDc=";
  };

  # go.mod has no requirements.
  vendorHash = null;

  subPackages = [ "cmd/reach" ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
    "-X main.buildCommit=${builtins.substring 0 7 rev}"
  ];

  # reach looks for reach-helper-<os>-<arch> beside its own (symlink-resolved)
  # executable, so the helpers live in libexec next to the real binary and
  # only `reach` itself goes on PATH.
  postBuild = lib.concatMapStrings
    ({ goos, goarch }: ''
      GOOS=${goos} GOARCH=${goarch} CGO_ENABLED=0 GOFLAGS=-trimpath \
        go build -ldflags "-s -w -X main.version=${reachVersion}" \
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
    $out/bin/reach --version | grep -F ${reachVersion}
    runHook postInstallCheck
  '';

  meta = {
    description = "Point your coding agent at any box you can SSH into, without installing the agent on the server";
    homepage = "https://github.com/arielherself/agentreach";
    changelog = "https://github.com/arielherself/agentreach/blob/${rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [
      {
        name = "arielherself";
        github = "arielherself";
        githubId = 107245128;
      }
    ];
    mainProgram = "reach";
    platforms = lib.platforms.unix;
  };
})
