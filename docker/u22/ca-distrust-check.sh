#!/bin/sh
# Fails the image build if any trust store in it still has a root that was
# distrusted after a CA compromise. First case: eMudhra (2026-10-17), whose
# intermediates' private keys can be derived from the public certificates; the
# distro fix removes "emSign ECC Root CA - G3" and "AAA Certificate Services".
# Checked by SHA-256 (other emSign roots stay in the fixed packages): the
# system bundle, every Java cacerts, Python certifi and Node's built-in roots.
set -u
BAD="86A1ECBA089C4A8D3BBE2734C612BA341D813E043CF9E8A862CD5C57A36BBE6B D7A7A0FB5D7E2731D771E9484EBCDEF71D5F0C3E0A2948782BC83EE0EA699EF4"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
found=""

pem_fps() {
  rm -f "$T"/c*.pem
  awk -v d="$T" '/BEGIN CERT/{n++} n{print > (d "/c" n ".pem")}' "$1"
  for f in "$T"/c*.pem; do
    [ -f "$f" ] && openssl x509 -in "$f" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//; s/://g'
  done
}
check() { # store, fingerprints on stdin
  while read -r fp; do
    case " $BAD " in *" $fp "*) found="$found $1:$(echo "$fp" | cut -c1-8)" ;; esac
  done
}

for b in /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/cert.pem; do
  [ -s "$b" ] || continue
  pem_fps "$b" > "$T/fps"; check "$b" < "$T/fps"
  break
done
for py in python3 python; do
  cb=$($py -m certifi 2>/dev/null) || continue
  [ -s "$cb" ] && { pem_fps "$cb" > "$T/fps"; check "certifi:$cb" < "$T/fps"; }
  break
done
if command -v node >/dev/null 2>&1; then
  node -e 'console.log(require("tls").rootCertificates.join("\n"))' > "$T/node.pem" 2>/dev/null
  pem_fps "$T/node.pem" > "$T/fps"; check "node $(node --version)" < "$T/fps"
fi
for c in /etc/ssl/certs/java/cacerts /usr/lib/jvm/*/lib/security/cacerts /usr/lib/jvm/*/jre/lib/security/cacerts /opt/java/openjdk/lib/security/cacerts; do
  [ -e "$c" ] || continue
  kt=$(command -v keytool || ls /usr/lib/jvm/*/bin/keytool /usr/lib/jvm/*/jre/bin/keytool 2>/dev/null | head -1)
  [ -n "$kt" ] || break
  LC_ALL=C "$kt" -list -v -keystore "$c" -storepass changeit 2>/dev/null | sed -n 's/.*SHA256: *//p' | tr -d ':\r' > "$T/fps"
  check "$(readlink -f "$c")" < "$T/fps"
done

if [ -n "$found" ]; then
  echo "ca-distrust-check: distrusted roots still trusted:$found" >&2
  exit 1
fi
echo "ca-distrust-check: OK"
