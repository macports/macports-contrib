#!/usr/bin/env port-tclsh

# Report any installed ports that either have supported_archs set to
# 'noarch' and probably shouldn't because they installed one or more
# Mach-O binary files, or that don't have supported_archs set to
# 'noarch' and probably should because they didn't install any Mach-O
# files.

package require macports
package require registry2

mportinit

foreach p [registry::entry imaged] {
    set binary_files [registry::file search id [$p id] binary 1]
    set archs [$p archs]
    if {$archs eq "noarch" && $binary_files ne {}} {
        ui_msg "[$p name] @[$p version]_[$p revision][$p variants] is marked as noarch but contains the following Mach-O files:"
        if {[$p state] eq "installed"} {
            set pathtype actual_path
        } else {
            set pathtype path
        }
        foreach f $binary_files {
            ui_msg "  [$f $pathtype]"
        }
    } elseif {$archs ne "noarch" && $binary_files eq {}} {
        ui_msg "[$p name] @[$p version]_[$p revision][$p variants] appears to contain no Mach-O files but is not marked as noarch."
    }
}
