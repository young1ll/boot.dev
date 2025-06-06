#!/usr/bin/env bash

g_log () { gum log --time rfc822 --level "$1" --prefix "[BOOTWIZARD]" "$2"; }
g_spin () { gum spin --spinner dot --show-output --show-error --title "$1" -- "$2"; }
g_confirm () { gum confirm "$1"; }