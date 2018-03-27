#!/opt/local/bin/port-tclsh
# -*- coding: utf-8; mode: tcl; c-basic-offset: 4; indent-tabs-mode: nil; tab-width: 4; truncate-lines: t -*- vim:fenc=utf-8:et:sw=4:ts=4:sts=4
#
# Copyright (c) 2018 The MacPorts Project
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Apple Computer, Inc. nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# This is a helper tool meant to be used to generate the cargo.crates option
# for the cargo 1.0 port group.
#
# https://github.com/macports/macports-ports/blob/master/_resources/port1.0/group/cargo-1.0.tcl

package require inifile

# helper functions

proc dequote {str} {
    return [string trim $str "\""]
}

proc usage {code} {
    puts stderr "Usage: [file tail $::argv0] \[--align=maxlen\] <path/to/Cargo.lock>"
    exit $code
}

# main

if {$argc == 0} {
    usage 0
} elseif {$argc == 1} {
    set maxlenmode no
    set cargolock [lindex $argv 0]
} elseif {$argc == 2} {
    if {[lindex $argv 0] ne "--align=maxlen"} {
        usage 1
    }
    set maxlenmode yes
    set cargolock [lindex $argv 1]
} else {
    usage 1
}

set crates {}
set maxlen_name 0
set maxlen_version 0

set fd [ini::open $cargolock "r"]
set metadata [ini::get $fd metadata]
ini::close $fd

foreach {key value} $metadata {
    set key [dequote $key]
    if {![regexp "^checksum (.*) (.*) " $key -> name version]} {
        error "regex did not match: $key"
    }
    set checksum [dequote $value]

    lappend crates [list $name $version $checksum]
    set maxlen_name    [expr max($maxlen_name, [string length $name])]
    set maxlen_version [expr max($maxlen_version, [string length $version])]
}

# sort
set crates [lsort -index 0 $crates]

# print result
puts -nonewline "cargo.crates"
foreach crate $crates {
    puts " \\"
    set name [lindex $crate 0]
    set version [lindex $crate 1]
    set checksum [lindex $crate 2]
    if {$maxlenmode} {
        puts -nonewline [format "    %-*s  %-*s  %s" $maxlen_name $name $maxlen_version $version $checksum]
    } else {
        puts -nonewline [format "    %-20s  %8s  %s" $name $version $checksum]
    }
}
puts ""

exit 0
