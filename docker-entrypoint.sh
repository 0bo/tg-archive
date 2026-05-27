#!/bin/sh
set -eu

SITE_DIR="${TG_ARCHIVE_SITE_DIR:-/workspace/mysite}"

run_tg_archive() {
  exec tg-archive "$@"
}

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing required file: $1" >&2
    echo "Run: docker compose run --rm tg-archive init" >&2
    exit 1
  fi
}

case "${1:-help}" in
  init)
    shift
    run_tg_archive --new --path="${1:-$SITE_DIR}"
    ;;
  sync)
    shift
    require_file "$SITE_DIR/config.yaml"
    run_tg_archive --sync \
      --config="$SITE_DIR/config.yaml" \
      --data="$SITE_DIR/data.sqlite" \
      --session="$SITE_DIR/session.session" \
      "$@"
    ;;
  build)
    shift
    require_file "$SITE_DIR/config.yaml"
    require_file "$SITE_DIR/template.html"
    if [ -f "$SITE_DIR/rss_template.html" ]; then
      run_tg_archive --build \
        --config="$SITE_DIR/config.yaml" \
        --data="$SITE_DIR/data.sqlite" \
        --template="$SITE_DIR/template.html" \
        --rss-template="$SITE_DIR/rss_template.html" \
        "$@"
    else
      run_tg_archive --build \
        --config="$SITE_DIR/config.yaml" \
        --data="$SITE_DIR/data.sqlite" \
        --template="$SITE_DIR/template.html" \
        "$@"
    fi
    ;;
  tg-archive)
    shift
    run_tg_archive "$@"
    ;;
  --)
    shift
    run_tg_archive "$@"
    ;;
  -*)
    run_tg_archive "$@"
    ;;
  help)
    cat <<EOF
Usage:
  docker compose run --rm tg-archive init [path]
  docker compose run --rm tg-archive sync [extra tg-archive flags]
  docker compose run --rm tg-archive build [extra tg-archive flags]
  docker compose run --rm tg-archive [tg-archive args]

Default site dir: $SITE_DIR
EOF
    ;;
  *)
    run_tg_archive "$@"
    ;;
esac
