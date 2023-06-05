#!/bin/bash

echo "Checking EULA agreement ..."

if [[ ${AGREE_EULA} = "yes" ]]; then
    exit 0
fi

echo ""
echo "Please agree to the EULA to continue:"
echo "https://github.com/cta-wave/dpctf-deploy/blob/master/End-User-License-Agreement.md"
echo ""

exit 1
