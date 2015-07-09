#!/bin/sh

dsconfigad -alldomains disable
dscl /Search -delete / CSPSearchPath "/Active Directory/YOURDOMAIN/All Domains"
dscl /Search/Contacts -delete / CSPSearchPath "/Active Directory/YOURDOMAIN/All Domains"
dscl /Search -create / SearchPolicy CSPSearchPath
dscl /Search -append / CSPSearchPath "/Active Directory/YOURDOMAIN/domain.com"
dscl /Search/Contacts -create / SearchPolicy CSPSearchPath
dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/YOURDOMAIN/domain.com"

exit 0