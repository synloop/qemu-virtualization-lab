#!/bin/bash

RAM="4G"
CPUS=2
SOCK="/tmp/qga.sock"

usage() {
  echo "Usage: $0 -d <disk.qcow2> -i <iso.iso>"
  exit 1
}

while getopts ":d:i:" opt; do
  case $opt in
    d) DISK="$OPTARG" ;;
    i) ISO="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$DISK" && -z "$ISO" ]]; then
  echo "Error : use at least -d or -i"
  usage
fi

QEMU_OPTS="-enable-kvm -m $RAM -smp cpus=$CPUS"
QEMU_OPTS+=" -vga virtio"
QEMU_OPTS+=" -netdev user,id=net0,hostfwd=tcp::4000-:22"
QEMU_OPTS+=" -device virtio-net-pci,netdev=net0"
QEMU_OPTS+=" -device virtio-serial"
QEMU_OPTS+=" -chardev socket,path=$SOCK,server=on,wait=off,id=qga0"
QEMU_OPTS+=" -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"

if [[ -n "$DISK" ]]; then
  QEMU_OPTS+=" -drive file=$DISK,format=qcow2,if=virtio"
fi

if [[ -n "$ISO" ]]; then
  QEMU_OPTS+=" -cdrom $ISO -boot d"
fi

qemu-system-x86_64 $QEMU_OPTS
