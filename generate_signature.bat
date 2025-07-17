@echo off
echo Generating Android package signature hash for MSAL authentication...
echo.
echo This script will generate the BASE64_ENCODED_PACKAGE_SIGNATURE needed for Azure app registration
echo and Android manifest configuration.
echo.
echo For DEBUG builds:
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
echo.
echo For RELEASE builds (if you have upload-keystore.jks):
echo keytool -exportcert -alias upload -keystore android\app\upload-keystore.jks ^| openssl sha1 -binary ^| openssl base64
echo.
echo Please copy the generated hash and:
echo 1. Replace "BASE64_ENCODED_PACKAGE_SIGNATURE" in android/app/src/main/AndroidManifest.xml
echo 2. Add this hash to your Azure app registration redirect URIs
echo.
pause 