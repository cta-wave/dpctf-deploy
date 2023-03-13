#!/bin/bash

if [[ ${AGREE_EULA} = true ]]; then
    exit 0;
fi;

echo ""
echo "Please agree to the EULA to continue:"
echo "https://github.com/cta-wave/dpctf-deploy/blob/master/End-User-License-Agreement.md"
echo ""

exit 1;