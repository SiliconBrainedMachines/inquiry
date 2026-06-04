# Pull Request

number: 233
title: "v0.7.2: Windows ape prompt tests should use git-resolved project root for junction paths"
url: "https://github.com/ccisnedev/inquiry/pull/233"
base: "main"
head: "231-windows-ape-prompt-tests-should-use-git-resolved-p"

## Body

Closes #231

## Summary
- make ape prompt test expectations derive the repository root from git instead of the entered path spelling
- add a Windows junction regression that proves the canonical git root is used when the repo is entered through an alternate path alias
- sync the CLI release surfaces for the bounded bug-fix release (0.7.2)

## Checklist
- [x] All tests pass
- [x] CHANGELOG updated
- [x] Version bumped
