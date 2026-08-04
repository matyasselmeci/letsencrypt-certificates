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

Get the download URLs by going to https://letsencrypt.org/certificates/ and
looking for the `pem` links.

"""

import csv
import os
import subprocess
import sys


def get_subject_hashes(pem_file: str):
    """Get old and new OpenSSL subject hashes for a certificate.
    
    Returns a tuple of (old_hash, new_hash), or None if the file doesn't exist.
    
    The hashes come from:
    - old_hash: openssl x509 -noout -subject_hash_old (< 1.0.0 format)
    - new_hash: openssl x509 -noout -subject_hash (modern format)
    """
    if not os.path.exists(pem_file):
        return None
    
    try:
        old_hash = subprocess.check_output(
            ["openssl", "x509", "-in", pem_file, "-noout", "-subject_hash_old"],
            encoding="latin-1",
            stderr=subprocess.DEVNULL
        ).strip()
        
        new_hash = subprocess.check_output(
            ["openssl", "x509", "-in", pem_file, "-noout", "-subject_hash"],
            encoding="latin-1",
            stderr=subprocess.DEVNULL
        ).strip()
        
        return (old_hash, new_hash)
    except subprocess.CalledProcessError:
        return None


def read_table(table_file):
    if not os.path.exists(table_file):
        print(f"Error: {table_file} not found", file=sys.stderr)
        raise FileNotFoundError(table_file)
    
    certificates = []
    pems = []
    with open(table_file) as f:
        reader = csv.reader(f, skipinitialspace=True)
        # Skip header if present
        next(reader, None)
        for row in reader:
            if row and not row[0].startswith("#"):
                pem_file = row[0].strip()
                url = row[1].strip() if len(row) > 1 else None
                certificates.append((pem_file, url))
                pems.append(pem_file)


def main(argv=()) -> int:
    argv = argv or sys.argv
    # Read the certificate table
    # Format: pem_filename,download_url
    # Example: isrgrootx1.pem,https://letsencrypt.org/certs/isrgrootx1.pem
    
    if len(sys.argv) > 1:
        table_file = sys.argv[1]
    else:
        table_file = "certificates.csv"
    
    certificates = read_table(table_file)
    pems = [row[0] for row in certificates]

    # Group certificates by their source pem files for symlink generation
    symlink_groups = {}  # Maps source pem to list of (old_hash, new_hash) pairs
    
    print("# Auto-generated Makefile from certificate table")
    print("# Regenerate with: python3 generate-makefile.py certificates.csv\n")
    
    # Collect all hashes for grouping
    for pem_file, url in certificates:
        hashes = get_subject_hashes(pem_file)
        if hashes:
            symlink_groups[pem_file] = hashes
    
    # Generate sources list (signing_policy files that are hand-created)
    sources = [pem.replace(".pem", ".signing_policy") for pem, _ in certificates]
    print(f"sources = {' \\\n          '.join(sources)}\n")
    
    # Generate targets list (derived .signing_policy and .0 files)
    # targets = []
    signpols = []
    dotzeros = []
    for pem_file in pems:
        hashes = symlink_groups.get(pem_file)
        if hashes:
            old_hash, new_hash = hashes
            # targets.append(f"{old_hash}.signing_policy")
            # targets.append(f"{new_hash}.signing_policy")
            # targets.append(f"{old_hash}.0")
            # targets.append(f"{new_hash}.0")
            signpols.append(f"{old_hash}.signing_policy {new_hash}.signing_policy")
            dotzeros.append(f"{old_hash}.0 {new_hash}.0")

    targets = signpols + dotzeros
    
    print(f"targets = {' \\\n          '.join(targets)}\n")

    print(f"pems = {' \\\n       '.join(pems)}\n")
    
    print("installfiles = $(pems) $(targets) $(sources)\n")
    print("installdir = /etc/grid-security/certificates\n")
    print("GET = curl -O")
    print("GET_WITH_NAME = curl -o")
    print("INSTALL = install")
    print("LINK = ln -s\n")
    
    # Generate phony targets
    print("all : $(pems) $(targets)\n")
    print("install : all")
    print("\t$(INSTALL) $(installfiles) $(DESTDIR)$(installdir)\n")
    print("clean :")
    print("\t$(RM) $(targets) *.pem\n")
    
    # Generate check target
    print("check : all")
    for pem_file, _ in certificates:
        print(f"\topenssl verify -CApath . {pem_file}")
    print()
    print("pems : $(pems)")
    print()
    
    # Generate symlink rules for .signing_policy files
    for pem_file, _ in certificates:
        hashes = symlink_groups.get(pem_file)
        if hashes:
            source_signing_policy = pem_file.replace(".pem", ".signing_policy")
            hash_targets = []
            old_hash, new_hash = hashes
            hash_targets.append(f"{old_hash}.signing_policy")
            hash_targets.append(f"{new_hash}.signing_policy")
            print(f"{' '.join(hash_targets)} : {source_signing_policy}")
            # make special variables: $< is the first prereq; $@ is the target
            print("\t$(LINK) $< $@")
    
    print()
    
    # Generate symlink rules for .0 files (certificates)
    for pem_file, _ in certificates:
        hashes = symlink_groups.get(pem_file)
        if hashes:
            hash_targets = []
            old_hash, new_hash = hashes
            hash_targets.append(f"{old_hash}.0")
            hash_targets.append(f"{new_hash}.0")
            print(f"{' '.join(hash_targets)} : {pem_file}")
            print("\t$(LINK) $< $@")
    
    print()
    
    # Generate download rules
    
    for pem_file, url in certificates:
        if not url:
            print(f"# {pem_file}: URL not specified in table")
            continue
        print(f"{pem_file} :")
        # Determine if we need -o flag (for renames) or not
        if "/" in url and not url.endswith(pem_file):
            print(f"\t$(GET_WITH_NAME) $@ {url}")
        else:
            print(f"\t$(GET) {url}")
    
    print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
