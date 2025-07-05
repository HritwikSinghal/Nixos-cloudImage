# Building a barebones NixOS cloudImage for proxmox for use in terraform providers.

- Clone this repo
- upload to your account so that you can run github actions (forks can't run them AFAIK)
- Go to repo settings -> Actions -> general and under `Workflow permissions`, allow tick `Read and write permissions`.
- Just run the workflow dispatch of the only github action you can see.
- it will create a release of `nixos.img` which you can use in terraform provider of your choice.

Profit!

This repo makes deploying NixOS VM's on proxmox via terraform as easy as ubuntu cloud-images.

Do note that this is UEFI only module. so you need to create the VM with bios set as UEFI in proxmox.