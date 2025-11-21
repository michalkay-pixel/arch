# GitHub Setup Instructions - Deploy Key

## Deploy Key Generated

Your deploy key has been generated and saved to:
- **Private key**: `C:\Users\Micha\.ssh\id_ed25519_arch_deploy`
- **Public key**: `C:\Users\Micha\.ssh\id_ed25519_arch_deploy.pub`

## Add Deploy Key to GitHub Repository

1. **Create your GitHub repository first** (if you haven't already):
   - Go to GitHub.com
   - Click "New repository"
   - Name it (e.g., `arch-install-script`)
   - **Do NOT** initialize with README, .gitignore, or license
   - Click "Create repository"
   - Copy the repository URL (e.g., `git@github.com:username/repo-name.git`)

2. **Add the deploy key to your repository**:
   - Go to your repository on GitHub
   - Click **Settings** → **Deploy keys** (in the left sidebar)
   - Click **Add deploy key**
   - **Title**: `Arch Install Script Deploy Key`
   - **Key**: Paste the public key below
   - ✅ **Check "Allow write access"** (if you want to push changes)
   - Click **Add key**

### Your Deploy Key (Public Key):
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCQcSpU7rHR+8nKQAyIqHCI7qnpfgGrXtYXwBxeTjST arch-install-script-deploy
```

## Create GitHub Repository

1. Go to GitHub.com
2. Click "New repository"
3. Name it (e.g., `arch-install-script`)
4. **Do NOT** initialize with README, .gitignore, or license (we already have files)
5. Click "Create repository"

## Push to GitHub

After adding the deploy key to your repository, provide me with your repository URL and I'll push the files.

**Repository URL format**: `git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git`

Or you can run these commands yourself:

```powershell
cd C:\Arch
git remote add origin git@github.com-arch-deploy:YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

**Note**: The SSH config is already set up to use the deploy key automatically when using the `github.com-arch-deploy` host alias.

## Testing the Deploy Key

To test if the deploy key works:

```powershell
ssh -T git@github.com-arch-deploy
```

You should see: "Hi USERNAME/REPO_NAME! You've successfully authenticated..."

