{
    description = "A very basic flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
    in {
        devShells.${system}.default = let
            ld_path = with pkgs; lib.makeLibraryPath [
              glfw
              vulkan-loader
                libGL
                libx11
                libxcursor
                libxrandr
                libxi
                libxkbcommon
                wayland
            ];
        in pkgs.mkShell {
            packages = with pkgs; [ zig zls wgpu-native wgsl-analyzer  vulkan-loader ];

            shellHook = ''
                export LD_LIBRARY_PATH=${ld_path}
                export LIBRARY_PATH=${ld_path}
            '';
        };
    };
}
