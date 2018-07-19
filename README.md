# extract-firmware
Extracts EFI firmware installer pkg from High Sierra installer

The original version of this script was from https://github.com/grahamgilbert/imagr/wiki/High-Sierra-Notes

This version includes a solution to get round the fact that the High Sierra 10.13.3 and later installers no longer include the update script previously included.

It has also been re-written to use [munkipkg](https://github.com/munki/munki-pkg) instead of pkgutil and pkgbuild as pkgbuild did not produce an installer package that worked under newer High Sierra versions.
