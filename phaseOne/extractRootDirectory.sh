#!/bin/bash
 
WDIR="$HOME/repatriationTask/_work"
 
if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <app-service-name>"
  exit 1
fi
 
rgName=$1
appName=$2
 
if [[ -f "$WDIR/wwwrootzip.zip" && -d "$WDIR/wwwroot" ]]; then
  echo "Root zip file and wwwroot directory already exist. Skipping extraction."
  exit 0
else
  echo "Root zip file or wwwroot directory not found. Proceeding with extraction."
fi
 
username=$(az webapp deployment list-publishing-profiles \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "[?publishMethod=='FTP'].[userName]" \
  -o tsv)
 
password=$(az webapp deployment list-publishing-profiles \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "[?publishMethod=='FTP'].[userPWD]" \
  -o tsv)
 
echo "Extracting wwwroot from App Service: $appName ..."
 
mkdir -p "$WDIR/urls"
[ -f $WDIR/urls/old_url.env ] && rm $WDIR/urls/old_url.env
 
 
appUrl=$(az webapp show \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "defaultHostName" \
  -o tsv)
 
scm_url_base=$(echo "$appUrl" | awk -F'.' '{print $1 ".scm." $2 "." $3}')
scm_url_root="https://$scm_url_base/api/zip/site/wwwroot/"
scm_url_default="https://$scm_url_base/api/vfs/default"
 
echo "export OLD_URL=${appUrl}" > $WDIR/urls/old_url.env
 
echo "OLD_URL set to ${appUrl}"
 
echo "Connecting to App Service: $appName"
echo "URL: $scm_url_root"
echo "User: $appName"
echo "Password: $password"
 
cred="\$$appName:$password"
echo "Credentials: $cred"
 
echo "Downloading the wwwroot zip file: "
curl -u "$cred" -o $WDIR/wwwrootzip.zip $scm_url_root -w "HTTP Status: %{http_code}\n" -v
curl_exit_code=$?
echo "Download completed. Zip file is in $WDIR/wwwrootzip.zip"
echo "Curl exit code: $curl_exit_code"
 
# Check if the downloaded file is actually a zip file
file_type=$(file $WDIR/wwwrootzip.zip)
echo "File type: $file_type"
 
# Check file size
file_size=$(stat -c%s "$WDIR/wwwrootzip.zip" 2>/dev/null || echo "0")
echo "File size: $file_size bytes"
 
if [ "$file_size" -eq 0 ]; then
    echo "ERROR: Downloaded file is empty. Authentication or URL might be incorrect."
    exit 1
fi
 
echo "Downloading default directory: "
curl -u "$cred" -o $WDIR/default $scm_url_default
echo -e "Download completed. \"Default\" file is in $WDIR/default\n"
 
echo "Unzipping the wwwroot: "
 
unzip $WDIR/wwwrootzip.zip -d $WDIR/wwwroot
 
echo -e "Unzipping completed. Files are in $WDIR/wwwroot\n"
 
 