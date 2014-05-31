#! /bin/sh
""":"
exec python $0 ${1+"$@"}
"""
__doc__ = """...Tester Script for pypi2port..."""

# -*- coding: utf-8 -*-
#! /usr/bin/env python

import argparse
import sys
import os
import urllib2
import hashlib
import zipfile
from progressbar import *
try:
    import xmlrpclib
except ImportError:
    import xmlrpc.client as xmlrpclib

client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')

def list_all():
    list_packages = client.list_packages()
    for package in list_packages:
        print package

def search(pkg_name):
    print "\n"
    values=client.search({'name':pkg_name})
    for value in values:
        for key in value.keys():
            print key,'-->',value[key]
        print "\n"

def release_data(pkg_name,pkg_version=None):
    print "\n"
    values = client.release_data(pkg_name,pkg_version)
    if values:
        for key in values.keys():
            print key,'-->',values[key]
    else:
        print "No such package found."
        print "Please specify the exact package name."
    print "\n"

def fetch(pkg_name,dict):
    checksum_md5 = dict['md5_digest']
    parent_dir = './sources'
    src_dir = parent_dir + '/' + pkg_name
    if not os.path.exists(parent_dir):
        os.makedirs(parent_dir)
        if not os.path.exists(src_dir):
            os.makedirs(src_dir)

    url = dict['url']
    file_name = src_dir + '/' + dict['filename']

    u = urllib2.urlopen(url)
    f = open(file_name,'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])

    widgets = ['Fetching: ', Percentage(), ' ', Bar(marker=RotatingMarker(),left='[',right=']'), ' ', ETA(), ' ', FileTransferSpeed()]
    pbar = ProgressBar(widgets=widgets, maxval=int(file_size))
    pbar.start()

    file_size_dl = 0
    block_sz = 1024
    while True:
        buffer = u.read(block_sz)
        if not buffer:
            break

        file_size_dl += len(buffer)
        f.write(buffer)
        pbar.update(file_size_dl)

    pbar.finish()
    print
    f.close()

    checksum_md5_calc = hashlib.md5(open(file_name).read()).hexdigest()
    if str(checksum_md5) == str(checksum_md5_calc):
        print 'Successfully fetched\n'
        ext = file_name.split('.')[-1]
        if ext == 'egg':
            zip = zipfile.ZipFile(file_name)
            for name in zip.namelist():
                if name.split("/")[0] == "EGG-INFO":
#                    print name
                    zip.extract(name,src_dir)

    else:
        print 'Aborting due to inconsistency on checksums\n'
        try:
            os.remove(file_name)
        except OSError, e:
            print "Error: %s - %s." % (e.filename,e.strerror)


def fetch_url(pkg_name,pkg_version=None):
    print "\n"
    values = client.release_urls(pkg_name,pkg_version)
    for value in values:
        fetch(pkg_name,value)        
    print "\n"


def main(argv):
    parser = argparse.ArgumentParser(description="Pypi2Port Tester")
    parser.add_argument('-l', '--list', action='store_true', dest='list',
                        default=False, required=False,
                        help='List all packages')
    parser.add_argument('-s', '--search', action='store', type=str,
                        dest='packages_search', nargs='*', required=False, 
                        help='Search for a package by <package_name>')
    parser.add_argument('-d', '--data', action='store',
                        dest='packages_data', nargs='*', type=str,
                        help='Releases data for a package by <package_name>')
    parser.add_argument('-f', '--fetch', action='store', type=str,
                        dest='package_fetch', nargs=2, required=False, 
                        help='Fetches distfiles for a package by <package_name> and <package_version>')
    options = parser.parse_args()
#    print options

    if options.list == True:
        list_all()
        return

    if options.packages_search:
        for pkg_name in options.packages_search:
            search(pkg_name)
        return

    if options.packages_data:
        pkg_name = options.packages_data[0]
        if len(options.packages_data) > 1:
            pkg_version = options.packages_data[1]
        else:
            if client.package_releases(pkg_name):
                pkg_version = client.package_releases(pkg_name)[0]
                release_data(pkg_name,pkg_version)
        return

    if options.package_fetch:
        pkg_name = options.package_fetch[0]
        if len(options.package_fetch) > 1:
            pkg_version = options.package_fetch[1]
            fetch_url(pkg_name,pkg_version)
        else:
            if client.package_releases(pkg_name):
                pkg_version = client.packages_releases(pkg_name)[0]
                fetch_url(pkg_name,pkg_version)
        return

    parser.print_help()
    parser.error("No input specified")

if __name__ == "__main__":
    main(sys.argv[1:])
