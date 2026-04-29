#!/usr/bin/env bash
# beads-starter installer — URL-stability shim.
#
# The canonical script has moved to always-on/beads-starter.sh.
# This shim exists only to keep the historical install URL working.
# Keep it a thin wrapper; do not add logic here.

set -eo pipefail

REAL_URL="https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh"

cat >&2 <<EOF
[beads-starter] Notice: this URL is now a thin redirect.
The canonical script has moved to:

  ${REAL_URL}

Please update your install command. The old URL will keep working for now,
but is deprecated.

EOF

curl -fsSL "$REAL_URL" | bash -s -- "$@"
