sudo virt-install \
  --name centos \
  --disk path=/var/lib/libvirt/images/templates/xc-template.qcow2,size=32 \
  --ram 16384 \
  --vcpus 4 \
  --os-variant centos7.0 \
  --sound none \
  --machine q35 \
  --rng /dev/urandom \
  --virt-type kvm \
  --import \
  --wait 0 \
  --cpu host \
  --network type=direct,source=enp109s0,source_mode=bridge,model=virtio
