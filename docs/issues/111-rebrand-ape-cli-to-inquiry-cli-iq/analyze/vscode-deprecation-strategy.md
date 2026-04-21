---
id: vscode-deprecation-strategy
title: "VS Code Extension Deprecation Strategy"
date: 2026-04-21
status: active
tags: [vscode, marketplace, deprecation, rebrand]
author: SOCRATES
---

# VS Code Extension Deprecation Strategy

## Current State

- Extension ID: `ccisnedev.ape-vscode`
- Display name: `APE`
- Published on VS Code Marketplace
- CI workflow: `.github/workflows/vscode-marketplace.yml`

## Goal

Users who have `ape-vscode` installed see a deprecation notice pointing them to the new `inquiry-vscode` extension.

## VS Code Marketplace Deprecation Mechanism

The VS Code Marketplace supports **extension replacement** via the `extensionPack` / replacement mechanism:

### Option 1: Marketplace deprecation flag (recommended)

VS Code Marketplace allows marking an extension as deprecated via the `vsce` CLI:

```bash
vsce unpublish ccisnedev.ape-vscode  # removes entirely — NOT recommended
```

Better approach — publish a final version with:

1. **`package.json` changes in the old extension:**
   ```json
   {
     "displayName": "APE (Deprecated — use Inquiry)",
     "description": "DEPRECATED: This extension has been replaced by Inquiry (ccisnedev.inquiry-vscode). Install Inquiry instead.",
     "extensionDependencies": ["ccisnedev.inquiry-vscode"]
   }
   ```

2. **README.md replacement:**
   ```markdown
   # APE (Deprecated)
   
   > This extension has been replaced by **[Inquiry](https://marketplace.visualstudio.com/items?itemName=ccisnedev.inquiry-vscode)**.
   > 
   > APE is now Inquiry. Install the new extension and uninstall this one.
   ```

3. **Strip all functionality** — remove activation events, commands, everything. The extension becomes an empty shell that only points to the replacement.

4. **Version bump** — publish as the next version so existing users get the auto-update with the deprecation notice.

### Option 2: Extension replacement via Marketplace API

Since ~2023, VS Code Marketplace supports a `replacement` field:

```json
{
  "badges": [],
  "replacement": {
    "extensionId": "ccisnedev.inquiry-vscode",
    "url": "https://marketplace.visualstudio.com/items?itemName=ccisnedev.inquiry-vscode"
  }
}
```

This shows a yellow banner in the Marketplace page and in VS Code: "This extension is deprecated. Use [Inquiry] instead."

Note: This field may need to be set via the Marketplace web UI or publisher portal, not via `vsce publish`.

## Execution Order

1. **First:** Publish `ccisnedev.inquiry-vscode` as a new extension (fully functional)
2. **Second:** Publish final version of `ccisnedev.ape-vscode` with deprecation notice + `extensionDependencies` pointing to the new one
3. **Third:** Mark `ape-vscode` as deprecated in the Marketplace portal

## CI/CD Impact

- New workflow or updated `vscode-marketplace.yml` must publish `inquiry-vscode`
- One-time manual step: publish the deprecation version of `ape-vscode`
- After deprecation, the old workflow can be removed

## Risk

- Users on `ape-vscode` won't automatically migrate — they must manually install the new extension
- The `extensionDependencies` approach will auto-install `inquiry-vscode` alongside, but won't uninstall the old one
- The deprecation banner is the best UX signal available
