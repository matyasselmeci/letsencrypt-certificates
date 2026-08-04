# Quick Start: Using the Makefile Generator

## Summary

The `generate-makefile.py` script eliminates 256 lines of Makefile duplication by reading a simple CSV table and generating the complete Makefile.

## Files

- `generate-makefile.py` — Generator script (reads CSV, outputs Makefile)
- `certificates.csv` — Certificate metadata table
- `make-signing-policy.sh` — Helper to generate `.signing_policy` files
- `GENERATOR.md` — Full documentation

## One-Time Setup

Everything is already set up. The current `Makefile` is equivalent to running:
```bash
python3 generate-makefile.py certificates.csv > Makefile
```

## Updating Certificates

### Add a new certificate

1. Add to `certificates.csv`:
   ```csv
   new-root.pem,https://example.com/new-root.pem
   ```

2. Download it:
   ```bash
   curl -o new-root.pem https://example.com/new-root.pem
   ```

3. Generate its signing_policy (if needed):
   ```bash
   bash make-signing-policy.sh new-root.pem > new-root.signing_policy
   ```

4. Regenerate Makefile:
   ```bash
   python3 generate-makefile.py certificates.csv > Makefile
   ```

### Remove a certificate

1. Remove from `certificates.csv`
2. Regenerate: `python3 generate-makefile.py certificates.csv > Makefile`

### Update a URL

1. Edit `certificates.csv`
2. Regenerate: `python3 generate-makefile.py certificates.csv > Makefile`

## How It Works

The generator:
1. Reads certificate filenames and URLs from `certificates.csv`
2. Runs `openssl x509` on each `.pem` file to get two subject hashes:
   - Old format: `openssl x509 -in <file.pem> -noout -subject_hash_old`
   - New format: `openssl x509 -in <file.pem> -noout -subject_hash`
3. Generates symlink rules so both hashes point to the certificate
4. Generates download and verification rules

Result: No manual hash entry needed, no duplication, single source of truth.
