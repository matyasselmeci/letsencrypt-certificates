#!/usr/bin/env python3
"""Generate Makefile from certificate data table.

This script reads a CSV table of certificate metadata and generates a Makefile
that automates downloading certificates and creating symlinks with their OpenSSL
subject hashes as filenames.

The CSV format is:
  pem_filename, download_url

Example:
  isrgrootx1.pem,https://letsencrypt.org/certs/isrgrootx1.pem
  lets-encrypt-e5.pem,https://letsencrypt.org/certs/2024/e5.pem
"""

import subprocess
import sys
import csv
from pathlib import Path


def get_subject_hashes(pem_file):
    """Get old and new OpenSSL subject hashes for a certificate.
    
    Returns a tuple of (old_hash, new_hash), or None if the file doesn't exist.
    
    The hashes come from:
    - old_hash: openssl x509 -noout -subject_hash_old (< 1.0.0 format)
    - new_hash: openssl x509 -noout -subject_hash (modern format)
    """
    if not Path(pem_file).exists():
        return None
    
    try:
        old_hash = subprocess.check_output(
            ["openssl", "x509", "-in", pem_file, "-noout", "-subject_hash_old"],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()
        
        new_hash = subprocess.check_output(
            ["openssl", "x509", "-in", pem_file, "-noout", "-subject_hash"],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()
        
        return (old_hash, new_hash)
    except subprocess.CalledProcessError:
        return None


def main():
    # Read the certificate table
    # Format: pem_filename,download_url
    # Example: isrgrootx1.pem,https://letsencrypt.org/certs/isrgrootx1.pem
    
    if len(sys.argv) > 1:
        table_file = sys.argv[1]
    else:
        table_file = "certificates.csv"
    
    if not Path(table_file).exists():
        print(f"Error: {table_file} not found", file=sys.stderr)
        sys.exit(1)
    
    certificates = []
    with open(table_file) as f:
        reader = csv.reader(f, skipinitialspace=True)
        # Skip header if present
        next(reader, None)
        for row in reader:
            if row and not row[0].startswith("#"):
                pem_file = row[0].strip()
                url = row[1].strip() if len(row) > 1 else None
                certificates.append((pem_file, url))
    
    # Group certificates by their source pem files for symlink generation
    symlink_groups = {}  # Maps source pem to list of (old_hash, new_hash) pairs
    
    print("# Auto-generated Makefile from certificate table")
    print("# Regenerate with: python3 generate-makefile.py certificates.csv\n")
    
    # Collect all hashes for grouping
    for pem_file, url in certificates:
        hashes = get_subject_hashes(pem_file)
        if hashes:
            old_hash, new_hash = hashes
            if pem_file not in symlink_groups:
                symlink_groups[pem_file] = []
            symlink_groups[pem_file].append((old_hash, new_hash))
    
    # Generate sources list (signing_policy files to download)
    sources = [pem.replace(".pem", ".signing_policy") for pem, _ in certificates]
    print(f"sources = {' \\\n          '.join(sources)}\n")
    
    # Generate targets list (derived .signing_policy and .0 files)
    targets = []
    for pem_file in certificates:
        hashes = symlink_groups.get(pem_file)
        if hashes:
            for old_hash, new_hash in hashes:
                targets.append(f"{old_hash}.signing_policy")
                targets.append(f"{new_hash}.signing_policy")
                targets.append(f"{old_hash}.0")
                targets.append(f"{new_hash}.0")
    
    targets_with_pems = targets + [pem for pem, _ in certificates]
    print(f"targets = {' \\\n          '.join(targets_with_pems)}\n")
    
    print("installfiles = $(targets) $(sources)\n")
    print("installdir = /etc/grid-security/certificates\n")
    print("GET = curl -O")
    print("GET_WITH_NAME = curl -o")
    print("INSTALL = install")
    print("LINK = ln -s\n")
    
    # Generate phony targets
    print("all : $(targets)\n")
    print("install : all")
    print("\t$(INSTALL) $(installfiles) $(DESTDIR)$(installdir)\n")
    print("clean :")
    print("\t$(RM) $(targets) *.pem\n")
    
    # Generate check target
    print("check : all")
    for pem_file, _ in certificates:
        print(f"\topenssl verify -CApath . {pem_file}")
    print()
    
    # Generate symlink rules for .signing_policy files
    print("# make special variables: $< is the first prereq; $@ is the target\n")
    for pem_file, _ in certificates:
        hashes = symlink_groups.get(pem_file)
        if hashes:
            source_signing_policy = pem_file.replace(".pem", ".signing_policy")
            hash_targets = []
            for old_hash, new_hash in hashes:
                hash_targets.append(f"{old_hash}.signing_policy")
                hash_targets.append(f"{new_hash}.signing_policy")
            print(f"{' '.join(hash_targets)} : {source_signing_policy}")
            print("\t$(LINK) $< $@")
    
    print()
    
    # Generate symlink rules for .0 files (certificates)
    for pem_file, _ in certificates:
        hashes = symlink_groups.get(pem_file)
        if hashes:
            hash_targets = []
            for old_hash, new_hash in hashes:
                hash_targets.append(f"{old_hash}.0")
                hash_targets.append(f"{new_hash}.0")
            print(f"{' '.join(hash_targets)} : {pem_file}")
            print("\t$(LINK) $< $@")
    
    print()
    
    # Generate download rules
    print("# Look for the `pem` links on < https://letsencrypt.org/certificates/ >.")
    print("# Download the \"self-signed\" root CAs, not the cross-signed ones.")
    print("# Include the ones marked \"backup\".\n")
    
    for pem_file, url in certificates:
        print(f"{pem_file} :")
        if url:
            # Determine if we need -o flag (for renames) or not
            if "/" in url and not url.endswith(pem_file):
                print(f"\t$(GET_WITH_NAME) $@ {url}")
            else:
                print(f"\t$(GET) {url}")
        else:
            print(f"\t# URL not specified in table")
    
    print()


if __name__ == "__main__":
    main()
