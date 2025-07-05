{
  description = "build nixos cloudimage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-generators,
      ...
    }:
    rec {
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      images = {
        pve_kvm = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          customFormats.pve_kvm =
            { config, modulesPath, ... }:
            {
              imports = [
                "${toString modulesPath}/virtualisation/proxmox-image.nix"
                "${toString modulesPath}/profiles/qemu-guest.nix" # needed, otherwise vm will get stuck on `waiting for device dev/disk/by-label/nixos`
              ];

              # These images are configured to log to the serial console, and not to your display. We override the image's default console=ttyS0.
              boot.kernelParams = lib.mkForce [ "console=tty0" ];

              # if you build 'raw', the final image size will be 20G. if you build 'qcow2', final image size will be ~3G with 'virtual size: 10 GiB' attribute.
              virtualisation.diskSize = 20 * 1024;

              # `(proxmox.qemuConf) additionalSpace bootSize` options also available to set if you want.
              proxmox.partitionTableType = "efi";
              proxmox.qemuConf.bios = "ovmf"; # to fix the failed assertions.

              system.stateVersion = "25.11";

              system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
                inherit lib config pkgs;
                inherit (config.virtualisation) diskSize;
                inherit (config.proxmox) partitionTableType;
                format = "qcow2-compressed";
                postVM = ''
                  mv $diskImage $out/nixos.img
                  echo "file img $out/nixos.img" > $out/nix-support/hydra-build-products
                '';
              };

              formatAttr = "qcow";
              fileExtension = ".img";
            };

          format = "pve_kvm";
        };
      };
    };
}
