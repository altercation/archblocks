# Contribute to ArchBlocks - HELP GROW IT!

Ideally I'd like to see ArchBlocks turn into a combination of:

1. Learning tool (easy way to onramp into Arch Linux in companion to the Beginner's page on the wiki, for example)

2. System specific fixes/tweaks (this is the SYSTEM_\* file that fixes the problem for that specific laptop/wifi-card/etc).

3. Recipes for installing both common and uncommon configuraiton (e.g. everything from an unencrypted ext4 single partition system to a fully encrypted swap/root/home 4 partition setup).

To this end I'd really like to have people submit new recipes (the aforementioned FILESYSTEM variants) as well as system specific blocks.

## Making a new block - considerations

I want to keep the blocks more or less completely swappable. So no weird inter-block dependencies (this is the reason for the FILESYSTEM_PRE_\* functions).

Try to be concise but clear in naming.

## Avoid new block types/categories

I'd like to avoid having a lot of block types. Right now it looks like the following list, but I'm considering subsuming the Phase 2 apps list (desktop, power, et al) under a prefix such as APPS or UTILS. Not sure yet. Feedback welcome. 

### Phase 1 - prechroot, filesystem install
PREFLIGHT
FILESYSTEM
BASEINSTALL

### Phase 2 - chroot & config
LOCALE
TIME
DAEMONS
HOSTNAME
NETWORK
KERNEL
RAMDISK
BOOTLOADER

### Phase 2 - system specific hardware tweaks/adjustments/etc.
SYSTEM

### Phase 2 - apps, x, desktop, etc.
DESKTOP
POWER
UTILS
AUDIO
VIDEO
WARN
XORG

### Phase 2 - Pull down user repos, sync data, etc.
HOMESETUP

### Phase 3 - Any post facto or post-reboot stuff? TBD
POSTFLIGHT

## Procedure for creating new blocks and relation to personal repos

I'd recommend creating a fork of this repo and test your blocks there prior to submitting them back.

I'm available on github/email/twitter/etc. almost universally under es@ethanschoonover.com / @ethanschoonover / ethanschoonover. I'm either ethanschoonover or altercation on most IRC networks.

