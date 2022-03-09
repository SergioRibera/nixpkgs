# shellcheck shell=bash

# Setup hook that installs specified desktop items.
#
# Example usage in a derivation:
#
#   { …, makeDesktopItem, copyDesktopItems, … }:
#
#   let desktopItem = makeDesktopItem { … }; in
#   stdenv.mkDerivation {
#     …
#     nativeBuildInputs = [ copyDesktopItems ];
#
#     desktopItems =  [ desktopItem ];
#     …
#   }
#
# This hook will copy files which are either given by full path
# or all '*.desktop' files placed inside the 'share/applications'
# folder of each `desktopItems` argument.

postInstallHooks+=(copyDesktopItems)

copyDesktopItems() {
    if [ "${dontCopyDesktopItems-}" = 1 ]; then return; fi

    if [ -z "$desktopItems" ]; then
        return
    fi

    for desktopItem in $desktopItems; do
        if [[ -f "$desktopItem" ]]; then
            echo \
              "Copying '$desktopItem' into '${!outputBin}/share/applications'"
            install -D -m 444 -t "${!outputBin}"/share/applications \
              "$desktopItem"
        else
            for f in "$desktopItem"/share/applications/*.desktop; do
                echo "Copying '$f' into '${!outputBin}/share/applications'"
                install -D -m 444 -t "${!outputBin}"/share/applications "$f"
            done
        fi
    done
}
