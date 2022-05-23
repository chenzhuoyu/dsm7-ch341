# CH341 Driver for Synology DSM 7

CH341 Driver for Synology DSM 7

The `ch431.c` source is copied from the Linux source tree:

https://github.com/torvalds/linux/blob/f2950b78547ffb8475297ada6b92bc2d774d5461/drivers/usb/serial/ch341.c

This is the newest version that compiles and works, between `v4.10-rc3` and `v4.10-rc4`. I have only tested on my `RS1221+`.

## Build

The Synology Package build process requires `root` for some weird reason I don't quiet understand, so you might want do this in a virtual machine to avoid messing with your own environment.

### 1. Setup the build environment.

Please refer to [this](https://help.synology.com/developer-guide/getting_started/system_requirement.html) and [this](https://help.synology.com/developer-guide/getting_started/prepare_environment.html) document.

After installing the toolchian, get yourself `root` for the whole process.

```bash
sudo su
```

All remaining steps assume that you are in the `root` shell.

### 2. Clone the source.

Assuming your toolkit is located at `/toolkit` as described in the document above, change it if yours not.

```bash
mkdir -p /toolkit/source
cd /toolkit/source
git clone https://github.com/chenzhuoyu/dsm7-ch341 ch341
```

**The directory name MUST be `ch341`, NOT `dsm7-ch341`, and it MUST in directory `/toolkit/source`.**

### 3. Build the driver.

```bash
rm -vrf /toolkit/build_env/ds.v1000-7.0/source  # clean up previous build products
/toolkit/pkgscripts-ng/PkgCreate.py -p v1000 ch341
```

Replace the `v1000` with your actual platform. You can find out which platform your NAS is using [on this page](https://kb.synology.com/en-global/DSM/tutorial/What_kind_of_CPU_does_my_NAS_have).

If successful, the build product should be at `/toolkit/build_env/ds.v1000-7.0/source/ch341/ch341.ko`. Again, replace `v1000` with your actual platform.

### 4. Load the driver into kernel.

Manage to copy the `ch341.ko` to the `/lib/modules` directory on your NAS.

For example, you can `scp` it from your build environment to the `/tmp` directory on your NAS, and execute `sudo mv /tmp/ch341.ko /lib/modules` on your NAS to move it into place.

Once the file is in place, execute the following commands on your NAS:

```bash
sudo modprobe usbserial
sudo insmod /lib/modules/ch341.ko
```

And voilà, you got a working CH341 driver.

## Automatically load at boot

**Please ensure your driver works before rebooting or performing any of the following steps, otherwise your NAS might not be able to boot again !**

All the steps below should executed on your NAS. Requires `root` access.

1. Make sure your driver is in `/lib/modules`.

2. Create `depmod` as a symlink to `kmod`.

DSM 7 does not ship with `depmod`, so we need to create one manually.

```bash
sudo ln -s /usr/bin/kmod /sbin/depmod
```

3. Register your driver to the module dependency registry.

```bash
sudo echo 'ch341:' >> /dev/modules/modules.dep
sudo depmod
```

Ignore any warnings the `depmod` command might generate.

4. Create a `.conf` file in `/etc/modules-load.d` with content:

File name is irrelevant, as long as it has the `.conf` extension, but conventionally it should be `70-usb-serial.conf`.

```bash
usbserial
ch341
```

5. Reboot.

After a successful reboot, you can use `lsmod` to ensure your driver was loaded.
