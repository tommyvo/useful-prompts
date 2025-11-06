---
description: "Generate a comprehensive .gitignore file at project root"
agent: build
---

# Generate .gitignore File

## Goal
Create a comprehensive `.gitignore` file at the root of the project that covers common development environments, frameworks, and operating systems.

## Process
1. **CRITICAL**: Check if `.gitignore` already exists at project root
2. If exists, ask user to confirm overwrite
3. Write `.gitignore` with the comprehensive template
4. Confirm file creation

## Instructions

### Step 1: Check Existing File

If `.gitignore` exists at project root, ask user: "A .gitignore file already exists. Overwrite it? (yes/no)"

If user says no, abort operation.

### Step 2: Create .gitignore File

Write this exact template to `.gitignore` at project root:

```gitignore
# VS Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# JetBrains IDEs (IntelliJ, RubyMine, WebStorm, etc.)
.idea/
*.iml
*.iws
*.ipr
out/

# Rails
*.rbc
capybara-*.html
.rspec
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep
/db/*.sqlite3
/db/*.sqlite3-journal
/db/*.sqlite3-*
/public/system
/coverage/
/spec/tmp
*.orig
rerun.txt
pickle-email-*.html
.byebug_history
/config/master.key
/config/credentials/*.key

# React / Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/versions
build/
dist/
.env.local
.env.development.local
.env.test.local
.env.production.local

# DevOps / Infrastructure
*.tfstate
*.tfstate.*
.terraform/
.terragrunt-cache/
*.pem
*.key
.envrc
.vagrant/

# Environment variables
.env
.env.*
!.env.example

# Logs
*.log
logs/

# OS - macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# OS - Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# OS - Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*
```

### Step 3: Confirm Creation

Output a simple confirmation message:
```
✅ Created .gitignore at project root
File: [absolute path to .gitignore]
```

## Output Format

Write directly to `.gitignore` file at project root. Provide confirmation message in chat only.
