carthage update   --cache-builds --platform mac --configuration Debug
export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate
    
cd Carthage/Build/Mac/


find . -name '*.framework' -type d | while read -r FRAMEWORK
do
echo "codesign $FRAMEWORK"
/usr/bin/codesign --sign  16B002250F14633E0CC0B2915EB8587D50772A42 --force --preserve-metadata=identifier,entitlements,flags --timestamp=none "$FRAMEWORK/Versions/A"
done
