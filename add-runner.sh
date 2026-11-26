#!/bin/sh
# Set up a project for deploys on this Pi: clone it to ~/<repo> and register a runner for it.
# Usage: ./add-runner.sh Draupnir        (needs: gh auth login, once)
# ponytail: one runner per repo because personal accounts can't share runners; move to an org to get one runner total
set -eu
OWNER=Knut-Eriksen
REPO=${1:?usage: add-runner.sh <Repo>}
NAME=$(echo "$REPO" | tr 'A-Z' 'a-z')
RUNNER="$HOME/runners/$NAME"

gh auth setup-git                          # lets git fetch private repos with gh's login
[ -d "$HOME/$NAME" ] || gh repo clone "$OWNER/$REPO" "$HOME/$NAME"

[ -d "$RUNNER" ] && { echo "runner already set up in $RUNNER"; exit 0; }
VERSION=$(gh api repos/actions/runner/releases/latest -q .tag_name | sed 's/^v//')
mkdir -p "$RUNNER" && cd "$RUNNER"
curl -fsSL "https://github.com/actions/runner/releases/download/v$VERSION/actions-runner-linux-arm64-$VERSION.tar.gz" | tar xz
sudo ./bin/installdependencies.sh >/dev/null
TOKEN=$(gh api -X POST "repos/$OWNER/$REPO/actions/runners/registration-token" -q .token)
./config.sh --unattended --url "https://github.com/$OWNER/$REPO" --token "$TOKEN" --name "$(hostname)-$NAME"
sudo ./svc.sh install && sudo ./svc.sh start
echo "done: $REPO deploys from ~/$NAME when you push to prod (remember its .env)"
