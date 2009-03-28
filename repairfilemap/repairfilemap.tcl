#!/usr/bin/tclsh

# $Id$
#
# Created by Kevin Ballard <eridius@macports.org>
# This creates a new file_map based on the contents of the receipts.
# Intended for use when file_map.db gets corrupted.
#
# The way this works is it parses all the receipts, pulls out the active ones,
# pulls out the image contents of each receipt, removes the image directory from
# the beginning of each path, and uses the resulting paths to construct an
# old-style file_map file. Once this is done, simply delete your file_map.db
# file and run a MacPorts command that access this file (such as deactivating
# a port, getting a contents list, or asking what port provides a file) and
# MacPorts will convert the file_map to a new file_map.db file.
#
# Note: this assumes you are using port images. If you aren't, this script will
# not work for you.
#
# This script is in the public domain. Do whatever you want with it. The only
# disclaimer is I am not liable for anything unexpected this script might do.

set tclpackage "/Library/Tcl"
if {[lindex $::argv 0] == "-t"} {
    set tclpackage [lindex $::argv 1]
}

catch {
	source [file join $tclpackage macports1.0 macports_fastload.tcl]
}
package require macports 1.0

if {[catch {mportinit} result]} {
	puts "Failed to initialize ports system, $result"
	exit 1
}

set file_map {}

proc parse_receipt {name} {
	global macports::registry.path

	set file_map {}

	set name [lindex [file split $name] end]

	set receipt_path [file join ${macports::registry.path} receipts $name]

	set versions {}
	set x [glob -nocomplain [file join $receipt_path *]]
	if { [string length $x] } {
		foreach path $x {
			lappend versions [lindex [file split $path] end]
		}
	}

	foreach version $versions {
		set receipt_file [file join $receipt_path $version receipt]

		if { [file exists $receipt_file.bz2] && [file exists /usr/bin/bzip2] } {
			set receipt_file $receipt_file.bz2
			set receipt_contents [exec /usr/bin/bzip2 -d -c $receipt_file]
		} elseif { [file exists $receipt_file] } {
			set receipt_handle [open $receipt_file r]
			set receipt_contents [read $receipt_handle]
			close $receipt_handle
		} else {
			return -code error "Registry erryr: receipt for ${name} ${version} seems to be compressed, but bzip2 couldn't be found."
		}

		if {![string match "# Version: 1.0*" $receipt_contents]} {
			return -code error "Registry error: receipt $name $version is an unknown format."
		}

		# Remove any line starting with #
		while {[regexp "(^|\n)#.*\n(.*)\$" $receipt_contents match foo receipt_contents]} {}
		array set receipt $receipt_contents

		if { [info exists receipt(active)] && $receipt(active) != 0 } {
			puts "Parsing active receipt for $name $version"
			# parse the contents list
			set contents $receipt(contents)

			foreach entry $contents {
				set path [lindex $entry 0]
				if { [string first $receipt(imagedir) $path] == 0 } {
					set path [string range $path [string length $receipt(imagedir)] end]
				} else {
					return -code error "Receipt error: Referenced file does not live in image directory."
				}
				set map_entry {}
				lappend map_entry $path
				lappend map_entry $name
				lappend file_map $map_entry
			}
		}
	}
	return $file_map
}

set names [glob -nocomplain [file join ${macports::registry.path} receipts *]]

set file_map {}

puts "Parsing receipts..."

foreach name $names {
	set file_map [concat $file_map [parse_receipt $name]]
}

set map_file [file join ${macports::registry.path} receipts file_map]
set map_handle [open $map_file w]
puts $map_handle $file_map
close $map_handle
puts "\n-- File map successfully built --"
