# Copy CoreSummit environment source files
cp -rf ${BUDDYBUILD_SECURE_FILES}/Production.swift ./OpenStack\ Summit/CoreSummit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Staging.swift ./OpenStack\ Summit/CoreSummit/

# Extract Vendor frameworks
mkdir Vendor
unzip -o ${BUDDYBUILD_SECURE_FILES}/Vendor.zip
