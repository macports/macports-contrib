#! /bin/sh
""":"
exec python $0 ${1+"$@"}
"""

import xmlrpclib
import sys
#import pdb
#from datetime import datetime

#startTime = datetime.now()
client = xmlrpclib.ServerProxy('http://pypi.python.org/pypi')

list_packages = client.list_packages()
count = 0
if len(sys.argv) > 1:
    end = int(sys.argv[1])
else:
    end = 5000

for package_name in list_packages:
    vers = client.package_releases(package_name)
    if vers:
        data = client.release_data(package_name,vers[0])
        if data:
#            pdb.set_trace()
            license = data['license']
            try:
                license = license.decode('utf-8','ignore')
                license = license.encode('utf-8','ignore')
                print package_name,vers,license
            except:
                print package_name,vers
        else:
            print package_name,vers
    else:
        print package_name
    count = count + 1
    if count == end:
        break;


#print "TIME TAKEN =",datetime.now()-startTime
