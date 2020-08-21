#!/bin/sh
echo "## Image environment"
grep "DISTRIB_DESCRIPTION=.*$" /etc/*-release | # extract only distrib description
    cut -d= -f2 # get distrib description value only

echo
echo "## Android environment"
echo "### Android SDKs"
sdkmanager --list --sdk_root=$ANDROID_HOME |
    awk '/Installed packages:/{flag=1; next} /Available Packages/{flag=0} flag'

if [ -n "$(which gcloud)" ]; then
  echo "### Google Cloud SDK"
  echo "| Name | Version |"
  echo "|------|---------|"
  gcloud --version | while read -r lib; do
      version=$(echo "${lib}" | awk '{ print $NF }')
      name=$(echo $lib | awk '{$NF=""; print $0}')
      echo "| $name | $version |"
  done

  echo "## Python environment"
  echo "### Python version"
  python3 --version | cut -d' ' -f2-
  echo "### PIP version"
  pip3 --version | cut -d' ' -f2-
  echo "### Installed PIP packages"
  echo "| Name | Version |"
  echo "|------|---------|"
  pip3 freeze | while read -r lib; do
      version=$(echo "$lib" | awk -F'=='  '{print $2}')
      name=$(echo "$lib" | awk -F'=='  '{print $1}')
      echo "| $name | $version |"
  done
fi

echo "## Ruby environment"
echo "### All ruby versions available"
echo "| Version |"
echo "|---------|"
rbenv versions --bare | while read -r version; do
    echo "| $version |"
done
echo "### rbenv"
rbenv --version | cut -d' ' -f2-
echo "### Default ruby version"
ruby --version | cut -d' ' -f2-
echo "### Installed gems:"
echo "| Name | Version |"
echo "|------|---------|"
gem list | while read -r lib; do
    version=$(echo $lib | awk -F"[()]" '{print $2}')
    name=$(echo $lib | awk -F"[()]" '{print $1}')
    echo "| $name | $version |"
done
echo

echo "## APT packages"
echo "| Name | Version | Architecture | Description |"
echo "| ---- | ------- | ------------ | ----------- |"
dpkg_format='| ${binary:Package} | ${Version} | ${Architecture} | ${binary:Summary} |\n'
dpkg-query --show --showformat="$dpkg_format"
