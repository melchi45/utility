## ✅ Option 1: Trust the Self-Signed Certificate (Recommended for Corporate Networks)
If you're in a corporate environment using a proxy or custom certificate authority (CA), you can configure Git to trust that certificate:

Get the CA certificate
Ask your IT team for the .crt file used by your organization.

Configure Git to use it
Run this command in Git Bash or your terminal:

```shell
git config --global http.sslCAInfo "C:/path/to/your/certificate.crt"
```

Replace the path with the actual location of the certificate file.

## ⚠️ Option 2: Disable SSL Verification (Not Recommended)
If you're in a trusted environment and just need a quick workaround:

```shell
git config --global http.sslVerify false
```
⚠️ Warning: This disables SSL verification globally, which can expose you to security risks. Use only if you understand the implications.

## ✅ Option 3: Use SSH Instead of HTTPS (Best Practice)
Since you've already set up SSH keys, you can clone using SSH:

```shell
git clone git@github.com:melchi45/utility.git
```

This avoids SSL issues entirely and is more secure for authenticated access.