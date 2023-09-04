# Enable Copilot on self signed certificate chain

In some environments, a Self Signed Certificate error may occur when using Copilot in Visual Studio Code. Copilot processes responses to requests by connecting to the server rather than the local environment. At this time, if it is not a normal network environment, the following Seft signed certificate error occurs.

```
"Error on ghost text request: (FetchError) self signed certificate in certificate chain"
```

In the Windows environment, extensions such as Win-CA exist, but in the Ubuntu environment, the certificate must be registered separately. However, if this is also blocked by in-house security, please try the following method.

First, check the path of your vscode and check the extension.js file in the dist path of the copilot extension.
If you change rejectUnauthorized to false in the file, the certificate will not be checked.

If this process is cumbersome, you can perform the following shell execution. 
Just enter the path that matches your vscode environment in _VSCODEDIR.

```
#!/bin/bash

_VSCODEDIR="$HOME/.vscode-server/extensions"
_COPILOTDIR=$(ls "${_VSCODEDIR}" | grep -E "github.copilot-[1-9].*" | sort -V | tail -n1) # For copilot
_COPILOTDEVDIR=$(ls "${_VSCODEDIR}" | grep "github.copilot-nightly-" | sort -V | tail -n1) # For copilot-nightly
_EXTENSIONFILEPATH="${_VSCODEDIR}/${_COPILOTDIR}/dist/extension.js"
_DEVEXTENSIONFILEPATH="${_VSCODEDIR}/${_COPILOTDEVDIR}/dist/extension.js"
if [[ -f "$_EXTENSIONFILEPATH" ]]; then
    echo "Found Copilot Extension, applying 'rejectUnauthorized' patches to '$_EXTENSIONFILEPATH'..."
    perl -pi -e 's/,rejectUnauthorized:[a-z]}(?!})/,rejectUnauthorized:false}/g' ${_EXTENSIONFILEPATH}
    sed -i.bak 's/d={...l,/d={...l,rejectUnauthorized:false,/g' ${_EXTENSIONFILEPATH}
else
    echo "Couldn't find the extension.js file for Copilot, please verify paths and try again or ignore if you don't have Copilot..."
fi
if [[ -f "$_DEVEXTENSIONFILEPATH" ]]; then
    echo "Found Copilot-Nightly Extension, applying 'rejectUnauthorized' patches to '$_DEVEXTENSIONFILEPATH'..."
    perl -pi -e 's/,rejectUnauthorized:[a-z]}(?!})/,rejectUnauthorized:false}/g' ${_DEVEXTENSIONFILEPATH}
    sed -i.bak 's/d={...l,/d={...l,rejectUnauthorized:false,/g' ${_DEVEXTENSIONFILEPATH}
else
    echo "Couldn't find the extension.js file for Copilot-Nightly, please verify paths and try again or ignore if you don't have Copilot-Nightly..."
fi
```
