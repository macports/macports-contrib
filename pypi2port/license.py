#! /bin/sh
""":"
exec python $0 ${1+"$@"}
"""

import xmlrpclib
#from datetime import datetime

#startTime = datetime.now()
client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')

list_packages = client.list_packages()
count = 0
for package_name in list_packages:
    vers = client.package_releases(package_name)
    if vers:
        data = client.release_data(package_name,vers[0])
        if data:
            license = data['license']
            license.encode('utf-8')
            print package_name,vers,license
        else:
            print package_name,vers
    else:
        print package_name
    count = count + 1
    if count == 50:
        break;

#print "TIME TAKEN =",datetime.now()-startTime
