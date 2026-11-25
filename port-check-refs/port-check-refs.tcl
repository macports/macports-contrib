#!/opt/local/bin/port-tclsh
# -*- coding: utf-8; mode: tcl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- vim:fenc=utf-8:ft=tcl:et:sw=4:ts=4:sts=4

#==================================================================================================
# Check all port references for dangling/invalid references, using the port registry. That
# includes every type of dependency, as well as replaced_by.
#--------------------------------------------------------------------------------------------------
# Usage:
#   $ port-check-refs.tcl | sort --ignore-case
#
# Example output for invalid depends:
#   bzr: invalid depends_lib -> py27-paramiko (from 'port:py27-paramiko')
#   digital_rf: invalid depends_build -> py27-pkgconfig (from 'port:py27-pkgconfig')
#   digital_rf: invalid depends_run -> py27-pandas (from 'port:py27-pandas')
# Example output for invalid replaced_by:
#   py310-last: invalid replaced_by -> py310-pylast
#--------------------------------------------------------------------------------------------------
# Copyright (c) 2026 The MacPorts Project
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
#==================================================================================================

package require macports

mportinit

# Fetch all ports from the PortIndex
set all_ports \
    [mportsearch ".*"]

# Build a case-insensitive lookup table of valid port names
array set valid_ports {}
foreach {name info_list} ${all_ports} {
    set valid_ports([string tolower ${name}]) 1
}

# The dependency types to check; this needs to include all possible types
set dep_keys { \
    depends_fetch \
    depends_extract \
    depends_build \
    depends_lib \
    depends_run \
    depends_test \
}

foreach {name info_list} ${all_ports} {
    array unset info
    array set info ${info_list}

    # Check standard dependencies (format: type:spec:portname)
    foreach key ${dep_keys} {
        if {[info exists info(${key})]} {
            foreach dep $info(${key}) {
                set target [lindex [split ${dep} ":"] end]
                if {![info exists valid_ports([string tolower ${target}])]} {
                    puts "${name}: invalid ${key} -> ${target} (from '${dep}')"
                }
            }
        }
    }

    # Check replaced_by (if present in index)
    if {[info exists info(replaced_by)]} {
        foreach target $info(replaced_by) {
            if {![info exists valid_ports([string tolower ${target}])]} {
                puts "${name}: invalid replaced_by -> ${target}"
            }
        }
    }
}

