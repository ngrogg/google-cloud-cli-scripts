# Install

## Overview
A Guide to installing the Google Cloud CLI package on Linux, assumes DEB based distro like Debian or Ubuntu. <br>
Instructions from [Google Cloud Platform Documentation](https://cloud.google.com/sdk/docs/install?authuser=0#deb) <br>

## Install guide
All but setting the default project can be safely copied, pasted and ran <br>
**Add GPG key,** <br>
`curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg` <br> <br>

**Create .deb,** <br>
`echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list` <br> <br>

**Install Google Cloud CLI,** <br>
`sudo apt update && sudo apt install google-cloud-cli` <br> <br>

**Initialize connection,** <br>
`gcloud init` <br> <br>

**Log in using Google account,** <br>
`gcloud auth login` <br> <br>

**Set default project,** <br>
`gcloud config set project PROJECT` <br> <br>
