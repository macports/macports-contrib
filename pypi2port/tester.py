# -*- coding: utf-8 -*-
#! /usr/bin/env python

import argparse
import sys
try:
    import xmlrpclib
except ImportError:
    import xmlrpc.client as xmlrpclib

client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')

def list_all():
    list_packages = client.list_packages()
    for package in list_packages:
        print package

def search(str):
    values=client.search({'name':str})[0]
    for key in values.keys():
        print key,'-->',values[key]

def data(str):
    version=client.search({'name':str})[0]['version']
    values=client.release_data(str,version)
    for key in values.keys():
        print key,'-->',values[key]

def main(args=None):
    parser = argparse.ArgumentParser(description='pip2port tester script.')

    parser.add_argument('package_name', 
                       metavar='package_name', type=str, nargs='?', 
                       help='Package_Name')
    parser.add_argument('-l', '--list_packages', action='store_const', 
                       dest='action', const='list_packages', required=False,
                       help='List all packages')
    parser.add_argument('-s', '--search', action='store_const',
                       dest='action', const='search', required=False,
                       help='Search for a package by <package_name>')
    parser.add_argument('-d', '--data', action='store_const',
                       dest='action', const='data', required=False,
                       help='Releases data for a package by <package_name>')
    

    options=parser.parse_args()
#    options=parser.parse_args('-s S1'.split())
#    print options

    if options.action == 'list_packages':
        list_all()
        return

    if options.action == 'search':
#        print options.package_name
        search(options.package_name)
        return

    if options.action == 'data':
        data(options.package_name)
        return


if __name__ == "__main__":
    main()
