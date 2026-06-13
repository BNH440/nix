#!/usr/bin/env bash
# Run the niri+noctalia test VM in QEMU on Apple Silicon Mac
# Usage: ./run-vm.sh [path-to-qcow2]
#
# Build the image first:
#   nix build .#image
# Then run:
#   ./run-vm.sh ./result/nixos.qcow2
#
# Or use the NixOS VM runner directly (uses a tmpfs-backed disk):
#   nix build .#vm
#   ./result/bin/run-niri-test-vm

set -euo pipefail

IMAGE="${1:-./result/nixos.qcow2}"

if [[ ! -f "$IMAGE" ]]; then
    echo "Error: Image not found at $IMAGE"
    echo ""
    echo "Build it first with:"
    echo "  nix build .#image"
    echo ""
    echo "Or use the VM runner:"
    echo "  nix build .#vm"
    echo "  ./result/bin/run-niri-test-vm"
    exit 1
fi

# Create a working copy so the original stays clean
WORK_IMAGE="./niri-test-vm.qcow2"
if [[ ! -f "$WORK_IMAGE" ]]; then
    echo "Creating working copy of disk image..."
    cp "$IMAGE" "$WORK_IMAGE"
    chmod u+w "$WORK_IMAGE"
fi

echo "Starting niri-test VM..."
echo "  Image: $WORK_IMAGE"
echo "  RAM:   4GB"
echo "  CPUs:  4"
echo ""
echo "Keybindings inside niri:"
echo "  Mod+T      → Open foot terminal"
echo "  Mod+D      → Open fuzzel launcher"
echo "  Mod+Q      → Close window"
echo "  Mod+H/J/K/L → Navigate (vim-style)"
echo "  Mod+Shift+E → Quit niri"
echo ""

exec qemu-system-aarch64 \
    -machine virt,highmem=on \
    -accel hvf \
    -cpu host \
    -smp 4 \
    -m 4096 \
    -drive "if=pflash,format=raw,readonly=on,file=$(dirname $(dirname $(readlink -f $(which qemu-system-aarch64))))/share/qemu/edk2-aarch64-code.fd" \
    -drive "if=virtio,format=qcow2,file=$WORK_IMAGE" \
    -device virtio-gpu-gl-pci,xres=1920,yres=1080 \
    -display cocoa,gl=es,show-cursor=on \
    -device qemu-xhci \
    -device usb-kbd \
    -device usb-tablet \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -serial mon:stdio
