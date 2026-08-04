#!/bin/bash


if [[ ! $1 ]]
then
    echo "Usage: $(basename "$0") *.pem"
    exit 2
fi

set -eu

for pem in "$@"
do
    [[ $pem = *.pem ]] || { echo "skipping $pem - not a pem file"; continue; }
    base=${pem%.pem}
    signing_policy=${base}.signing_policy
    # [[ -f $signing_policy ]] && { echo "skipping $pem - $signing_policy exists"; continue; }

    # Get the subject in old-style format.
    subject=$(openssl x509 -in "$pem" -noout -subject -nameopt compat | sed -e 's/^subject *= *//')
    # shellcheck disable=SC2001
    quoted_subject="$(sed -e "s/'/\\\\'/g" <<<"$subject")"

    if [[ $subject =~ CN' '*=' '*ISRG' ' ]]
    then
        cond_subjects='"/C=US/O=Let'\\\''s Encrypt/CN=*"'
    else
        cond_subjects='"/CN=*"'
    fi

    printf "%-14s %-7s %s\n" \
        "access_id_CA"  "X509"  "'${quoted_subject}'" \
        "pos_rights"  "globus"  "CA:sign" \
        "cond_subjects"  "globus"  "'${cond_subjects}'"
        # > "$signing_policy"  && \
        # echo "Wrote $signing_policy"
done

