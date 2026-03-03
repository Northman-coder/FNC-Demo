#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}" )/.."

SKIP_ASSETS=false
if [[ "${1:-}" == "--skip-assets" ]]; then
	SKIP_ASSETS=true
fi

export RAILS_ENV="${RAILS_ENV:-production}"
export RACK_ENV="${RACK_ENV:-production}"
export NODE_ENV="${NODE_ENV:-production}"

ruby -v
bundle -v

bundle check >/dev/null 2>&1 || bundle install --jobs 4 --retry 3

# Ensure bin/bundle matches the installed Bundler version in the Render image.
bundle binstubs bundler --force

if [[ "$SKIP_ASSETS" == "false" ]]; then
	echo "==> Precompiling assets"
	SKIP_AUTO_MIGRATE=1 SKIP_AUTO_SEED=1 SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
else
	echo "==> Skipping assets precompile (--skip-assets)"
fi