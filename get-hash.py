import argparse
import shlex
import subprocess
# curl https://api.github.com/repos/gfx-rs/wgpu-native/releases/tags/v29.0.1.1

REPO = "https://github.com/gfx-rs/wgpu-native"
VERSION = "v29.0.1.1"
PLATFORMS = {
    "android": ("aarch64", "armv7", "i686", "x86_64"),
    "ios": ("aarch64", "x86_64"),
    "linux": ("aarch64", "x86_64"),
    "macos": ("aarch64", "x86_64"),
    "windows": ("aarch64", "i686", "x86_64"),
}
MODES = ("debug", "release")
# WINDOWS_TOOLCHAINS = ("gnu", "msvc")
WINDOWS_TOOLCHAINS = ("msvc",)
FETCH_CMD = ["zig", "fetch"]


def parse_args():
    parser = argparse.ArgumentParser(description="Fetch wgpu-native release archives.")
    parser.add_argument("--repo", default=REPO, help="Release repository URL")
    parser.add_argument("--version", default=VERSION, help="Release tag, for example v29.0.1.1")
    parser.add_argument("--platform", dest="platforms", nargs="+", choices=PLATFORMS, default=list(PLATFORMS))
    parser.add_argument("--arch", nargs="+", help="Architectures to fetch")
    parser.add_argument("--mode", nargs="+", choices=MODES, default=list(MODES))
    parser.add_argument("--windows-toolchain", nargs="+", choices=WINDOWS_TOOLCHAINS, default=list(WINDOWS_TOOLCHAINS))
    parser.add_argument("--ios-target", choices=("device", "simulator", "both"), default="both")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running them")
    return parser.parse_args()


def archive_names(args):
    for platform in args.platforms:
        architectures = args.arch or PLATFORMS[platform]
        invalid = set(architectures) - set(PLATFORMS[platform])
        if invalid:
            raise ValueError(f"invalid architecture(s) for {platform}: {', '.join(sorted(invalid))}")

        for arch in architectures:
            variants = ("",)
            if platform == "ios":
                variants = ("", "-simulator") if args.ios_target == "both" else (f"-{args.ios_target}",)
                if arch == "x86_64":
                    variants = tuple(variant for variant in variants if variant == "-simulator")
            elif platform == "windows":
                variants = tuple(f"-{toolchain}" for toolchain in args.windows_toolchain)

            for variant in variants:
                for mode in args.mode:
                    yield f"wgpu-{platform}-{arch}{variant}-{mode}.zip"


def main():
    args = parse_args()
    base_url = f"{args.repo.rstrip('/')}/releases/download/{args.version}"

    for archive in archive_names(args):
        command = [*FETCH_CMD, f"{base_url}/{archive}"]
        print(shlex.join(command))
        if not args.dry_run:
            result = subprocess.run(command, capture_output=True, text=True, check=False)
            if result.stdout:
                print(result.stdout, end="")
            if result.stderr:
                print(result.stderr, end="")
            if result.returncode:
                raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()