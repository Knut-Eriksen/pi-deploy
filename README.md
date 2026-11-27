# pi-deploy

Push to `production` → the project rebuilds and restarts on the Pi.

```
git push origin production
  → GitHub runs the project's deploy.yml
  → which calls pi-deploy.yml here
  → the Pi's runner does: cd ~/<project> && git checkout production && docker compose up -d --build
```

## Set up the Pi (once)

```sh
curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker $USER   # then log out and in
sudo apt install gh && gh auth login
git clone https://github.com/Knut-Eriksen/pi-deploy ~/pi-deploy
```

## Add a project (once per project)

**1. In the project repo**, add `.github/workflows/deploy.yml`. Change only `dir`: the repo name exactly as on GitHub, which is also its folder on the Pi:

```yaml
name: deploy
on:
  push:
    branches: [production]

jobs:
  deploy:
    uses: Knut-Eriksen/pi-deploy/.github/workflows/pi-deploy.yml@main
    with:
      dir: Draupnir
```

The project needs a `compose.yaml` or `docker-compose.yml`.

**2. On the Pi:**

```sh
~/pi-deploy/add-runner.sh Draupnir
```

This clones the project to `~/Draupnir` (skipped if it is already there) and starts a runner for it.

**3. Put the project's `.env` file in `~/Draupnir`** (it isn't in git).

## Deploy

```sh
git push origin production
```

See how it went in the repo's **Actions** tab.

## Good to know

- Your `.env` and data folders on the Pi survive deploys, because they aren't tracked by git.
- Don't edit tracked files on the Pi. If you do, the deploy fails instead of overwriting them.
- If the Pi is off when you push, the deploy runs when the Pi comes back online.
- Each repo has its own runner, because GitHub doesn't share runners between repos on a personal account. Each runner idles at a few dozen MB.
