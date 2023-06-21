#!/usr/bin/env bash

cd android/app || exit 1
source ../key.properties

#rm -rf ${storeFile}
#keytool -v \
#  -genkey \
#  -storetype JKS \
#  -keyalg RSA \
#  -keysize 2048 \
#  -validity 36500 \
#  -alias ${keyAlias} \
#  -storepass ${storePassword} \
#  -keypass ${keyPassword} \
#  -keystore ${storeFile} \
#  -dname "CN=Admin, OU=SalesTracker, O=Bitanon, L=Dhaka, S=Dhaka, C=BD"

#keytool -export -rfc \
#  -file upload_certificate.pem \
#  -alias ${keyAlias} \
#  -storepass ${storePassword} \
#  -keypass ${keyPassword} \
#  -keystore ${storeFile}

keytool -list -v \
  -alias ${keyAlias} \
  -storepass ${storePassword} \
  -keypass ${keyPassword} \
  -keystore ${storeFile}
