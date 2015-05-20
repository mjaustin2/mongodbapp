#!/usr/bin/env bash

# =========================== DOWNLOAD ==================================

# Get latest Production Relase version number
echo "--> Getting Production Release version number"
VERSION=$(curl -s https://www.mongodb.org/downloads | grep -o 'Current Stable Release (.*)' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
echo "--> Production Release: $VERSION"

# Create download url
DOWNLOAD_URL="https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-$VERSION.tgz"

# Download latest mongodb for mac
echo "--> Downloading: $DOWNLOAD_URL"
curl -o /tmp/mongodb.tgz $DOWNLOAD_URL

# Clean old mongodb dir
echo "--> Cleaning directory $(pwd)/Vendor/mongodb"
rm -rf $(pwd)/Vendor/mongodb

# Create dir
echo "--> Creating directory $(pwd)/Vendor/mongodb"
mkdir -p $(pwd)/Vendor/mongodb

# Extract
echo "--> Unzipping..."
tar xvzf /tmp/mongodb.tgz -C /tmp

# move files
echo "--> Moving files to $(pwd)/Vendor/mongodb/"
mv /tmp/mongodb-osx-x86_64-*/* Vendor/mongodb

# cleanup
echo "--> Removing /tmp/mongodb.tgz"
rm /tmp/mongodb.tgz

echo "--> Removing /tmp/mongodb-osx-x86_64-*"
rm -r /tmp/mongodb-osx-x86_64-*

echo "--> Download completed!"


# =========================== PUBLISH ==================================

echo "--> Clean build folder"
rm -rf build/

echo "--> Build with defaults"
xcodebuild

echo "--> Zip"
cd build/Release
zip -r -y ~/Desktop/MongoDB.zip MongoDB.app
cd ../../

# Get zip file size
FILE_SIZE=$(du ~/Desktop/MongoDB.zip | cut -f1)

# Get app version
VERSION=$(defaults read ~/Code/mongodbapp/MongoDB/Info.plist CFBundleShortVersionString)

# Get date
DATE_TIME=$(date +"%a, %d %b %G %H:%M:%S %z")

echo "--> Creting a git tag"
git tag $VERSION

echo "--> Echo Appcast item"
echo "============================="
echo "
<item>
  <title>{VERSION TITLE HERE}</title>
  <description>
    <![CDATA[
      <h2>{VERSION TITLE HERE}</h2>
      <ul>
        <li>{NEW FEAUTES OR CHANGES}</li>
      </ul>
    ]]>
  </description>
  <pubDate>$DATE_TIME</pubDate>
  <enclosure url=\"https://github.com/gcollazo/mongodbapp/releases/download/$VERSION/MongoDB.zip\" sparkle:version=\"$VERSION\" length=\"$FILE_SIZE\" type=\"application/octet-stream\"/>
  <sparkle:minimumSystemVersion>10.10</sparkle:minimumSystemVersion>
</item>
"
echo "============================="

echo "--> Done"
echo ""


echo "Next steps:"
echo ""
echo "git push origin --tags"
echo ""
echo "Upload the zip file to GitHub"
echo "https://github.com/gcollazo/mongodbapp/releases/tag/$VERSION"
echo ""
echo "Update Appcast file."
echo ""
echo ""