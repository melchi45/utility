Absolutely! Here's the full English translation of the SSH setup for using two GitHub accounts—user1 and user2—simultaneously:

# 🔐 Using Two GitHub Accounts via SSH: user1 and user2
## ✅ 1. Generate SSH Keys for Each Account
# For user1
```
ssh-keygen -t rsa -b 4096 -C "user1@github.com"
```
# Save as: ~/.ssh/id_rsa_user1

# For user2
```
ssh-keygen -t rsa -b 4096 -C "user2@github.com"
```
# Save as: ~/.ssh/id_rsa_user2
Be sure to specify unique filenames when prompted, so the keys don’t overwrite each other.

## ✅ 2. Add Public Keys to GitHub
Go to each GitHub account:


Settings → SSH and GPG keys → New SSH key
Add id_rsa_user1.pub to the user1 account

Add id_rsa_user2.pub to the user2 account

## ✅ 3. Configure SSH (~/.ssh/config)
```
Host github-user1
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_rsa_user1

Host github-user2
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_rsa_user2
```
Port 443 is used instead of 22 in case your network blocks standard SSH traffic.

## ✅ 4. Set Git Remote URLs per Account
For a repository owned by user1:
```
git remote set-url origin git@github-user1:user1/repo-name.git
```
For a repository owned by user2:
```
git remote set-url origin git@github-user2:user2/another-repo.git
```
## ✅ 5. Test SSH Connections
```
ssh -T git@github-user1
ssh -T git@github-user2
```
You should see messages like:

코드
Hi user1! You've successfully authenticated...
Hi user2! You've successfully authenticated...
