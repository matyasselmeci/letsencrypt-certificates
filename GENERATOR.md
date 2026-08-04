# Makefile Generator

This project uses `generate-makefile.py` to eliminate duplication in the Makefile.

## Overview

The original Makefile had significant duplication:
- Each certificate had two OpenSSL subject hashes (old and new format)
- Each hash required both `.signing_policy` and `.0` symlink targets
- Download rules for each certificate
- Verification rules for each certificate
- This resulted in hundreds of lines of nearly identical rules

The generator script reads a simple CSV table (`certificates.csv`) and automatically generates the complete Makefile by:
1. Reading the certificate metadata (filename and download URL)
2. Computing the OpenSSL subject hashes from the actual `.pem` files using:
   - `openssl x509 -in <file.pem> -noout -subject_hash_old` (old format)
   - `openssl x509 -in <file.pem> -noout -subject_hash` (new format)
3. Generating all symlink rules, download rules, and verification commands

## Certificate Table Format

`certificates.csv` is a simple CSV with header row:
```
# Certificate definitions: pem_filename, download_url
isrgrootx1.pem,https://letsencrypt.org/certs/isrgrootx1.pem
lets-encrypt-e5.pem,https://letsencrypt.org/certs/2024/e5.pem
```

Columns:
- **pem_filename**: The local filename for the certificate (must exist when regenerating)
- **download_url**: The URL to download the certificate from

## Workflow

### Adding a New Certificate

1. Add a row to `certificates.csv`:
   ```
   new-cert.pem,https://example.com/cert.pem
   ```

2. Download the certificate:
   ```bash
   curl -O https://example.com/cert.pem -o new-cert.pem
   ```

3. Generate the corresponding signing_policy file:
   ```bash
   bash make-signing-policy.sh new-cert.pem > new-cert.signing_policy
   ```

4. Regenerate the Makefile:
   ```bash
   python3 generate-makefile.py certificates.csv > Makefile
   ```

### Removing a Certificate

1. Remove its row from `certificates.csv`

2. Regenerate:
   ```bash
   python3 generate-makefile.py certificates.csv > Makefile
   ```

### Updating a URL

Simply edit `certificates.csv` and regenerate:
```bash
python3 generate-makefile.py certificates.csv > Makefile
```

## Understanding the Generated Makefile

### Hash Derivation

For each certificate, the script computes two hashes:
- `subject_hash_old`: Used by older OpenSSL versions (< 1.0.0)
- `subject_hash`: Used by modern OpenSSL versions

Example for `isrgrootx1.pem`:
```bash
$ openssl x509 -in isrgrootx1.pem -noout -subject_hash_old
4042bcee

$ openssl x509 -in isrgrootx1.pem -noout -subject_hash
6187b673
```

### Generated Rules

For each certificate, the Makefile contains:

1. **Symlink rules for `.signing_policy` files**:
   ```make
   4042bcee.signing_policy 6187b673.signing_policy : isrgrootx1.signing_policy
   	$(LINK) $< $@
   ```

2. **Symlink rules for certificate files** (`.0` extension):
   ```make
   4042bcee.0 6187b673.0 : isrgrootx1.pem
   	$(LINK) $< $@
   ```

3. **Download rules**:
   ```make
   isrgrootx1.pem :
   	$(GET) https://letsencrypt.org/certs/isrgrootx1.pem
   ```

4. **Verification rules** (in `make check`):
   ```make
   check : all
   	openssl verify -CApath . isrgrootx1.pem
   ```

## Maintenance

- Keep `certificates.csv` in sync with the actual certificates you need
- When Let's Encrypt updates their certificate URLs, update `certificates.csv` and regenerate
- The generator automatically fetches hashes from the actual PEM files, ensuring consistency
- No manual hash entry is needed—it's impossible to get out of sync

## Why This Approach?

This generator solves several problems with the original Makefile:

1. **Eliminates duplication**: Certificate metadata is defined once in CSV format
2. **Single source of truth**: Hashes are computed from actual files, never manually entered
3. **Automatic updates**: Easy to add/remove/modify certificates without manual Makefile editing
4. **Maintainability**: Changes to the Makefile structure only need updates in one place (the generator)
5. **Correctness**: OpenSSL hash extraction is automated and verifiable
