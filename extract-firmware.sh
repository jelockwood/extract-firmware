#!/bin/sh
# Based on investigations and work by Pepijn Bruienne
# Expects a single /Applications/Install macOS High Sierra*.app on disk

IDENTIFIER="com.foo.FirmwareUpdateStandalone"
VERSION=1.0

# find the Install macOS High Sierra.app and mount the embedded InstallESD disk image
echo "Mounting High Sierra ESD disk image..."
/usr/bin/hdiutil mount /Applications/Install\ macOS\ High\ Sierra*.app/Contents/SharedSupport/InstallESD.dmg

# expand the FirmwareUpdate.pkg so we can copy resources from it
echo "Expanding FirmwareUpdate.pkg"
/usr/sbin/pkgutil --expand /Volumes/InstallESD/Packages/FirmwareUpdate.pkg /tmp/FirmwareUpdate

# we don't need the disk image any more
echo "Ejecting disk image..."
/usr/bin/hdiutil eject /Volumes/InstallESD

# make a place to stage our pkg resources
/bin/mkdir -p /tmp/FirmwareUpdateStandalone/scripts

# recreate missing update script
if [ ! -e /tmp/FirmwareUpdate/Scripts/postinstall_actions/update ]; then
/bin/mkdir -p /tmp/FirmwareUpdate/Scripts/postinstall_actions
cat << 'EOF' >> /tmp/FirmwareUpdate/Scripts/postinstall_actions/update
#!/bin/sh

/usr/libexec/FirmwareUpdateLauncher -p "$PWD/Tools"
/usr/libexec/efiupdater -p "$PWD/Tools/EFIPayloads"
EOF
fi
# copy the needed resources
echo "Copying package resources..."
/bin/cp /tmp/FirmwareUpdate/Scripts/postinstall_actions/update /tmp/FirmwareUpdateStandalone/scripts/postinstall
# add an exit 0 at the end of the script
echo "" >> /tmp/FirmwareUpdateStandalone/scripts/postinstall
echo "" >> /tmp/FirmwareUpdateStandalone/scripts/postinstall
echo "exit 0" >> /tmp/FirmwareUpdateStandalone/scripts/postinstall
/bin/cp -R /tmp/FirmwareUpdate/Scripts/Tools /tmp/FirmwareUpdateStandalone/scripts/

# build the package
echo "Building standalone package..."
/usr/bin/pkgbuild --nopayload --scripts /tmp/FirmwareUpdateStandalone/scripts --identifier "$IDENTIFIER" --version "$VERSION" /tmp/FirmwareUpdateStandalone/FirmwareUpdateStandalone.pkg

# clean up
/bin/rm -r /tmp/FirmwareUpdate
/bin/rm -r /tmp/FirmwareUpdateStandalone/scripts
