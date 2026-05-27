
![favicon](https://user-images.githubusercontent.com/547147/111869334-eb48f100-89a4-11eb-9c0c-bc74cdee197a.png)


**tg-archive** is a tool for exporting Telegram group chats into static websites, preserving chat history like mailing list archives.

**IMPORTANT:** I'm no longer actively maintaining or developing this tool. Can review and merge PRs (as long as they're not massive and are clearly documented).

## Preview
The [@fossunited](https://tg.fossunited.org) Telegram group archive.

![image](https://user-images.githubusercontent.com/547147/111869398-44188980-89a5-11eb-936f-01d98276ba6a.png)


## How it works
tg-archive uses the [Telethon](https://github.com/LonamiWebs/Telethon) Telegram API client to periodically sync messages from a group to a local SQLite database (file), downloading only new messages since the last sync. It then generates a static archive website of messages to be published anywhere.

## Features
- Periodically sync Telegram group messages to a local DB.
- Download user avatars locally.
- Download and embed media (files, documents, photos).
- Renders poll results.
- Use emoji alternatives in place of stickers.
- Single file Jinja HTML template for generating the static site.
- Year / Month / Day indexes with deep linking across pages.
- "In reply to" on replies with links to parent messages across pages.
- RSS / Atom feed of recent messages.

## Install
- Get [Telegram API credentials](https://my.telegram.org/auth?to=apps). Normal user account API and not the Bot API.
  - If this page produces an alert stating only "ERROR", disconnect from any proxy/vpn and try again in a different browser.

- Install with: `uv pip install tg-archive` (tested with Python 3.13.2).

## Docker (including Windows Docker Desktop)

This repository includes a Docker setup that keeps all runtime files on the host, so deleting/recreating containers does not lose your data.

### 1) Build the image

```bash
docker compose build
```

### 2) Initialize a new archive workspace

```bash
docker compose run --rm tg-archive init
```

This creates `./workspace/mysite` on your host (default) with `config.yaml`, templates, and static files.

### 3) Configure Telegram credentials

Edit `./workspace/mysite/config.yaml` and set `api_id` / `api_hash` / `group`.

Or set environment variables in PowerShell before running commands:

```powershell
$env:API_ID="123456"
$env:API_HASH="your_api_hash"
```

### 4) Sync and build

```bash
docker compose run --rm tg-archive sync
docker compose run --rm tg-archive build
```

On first sync, Telegram login is interactive (phone number + auth code), and `session.session` will be written under `./workspace/mysite`.

### 5) Preview generated static site (optional)

```bash
docker compose --profile preview up preview
```

Then open http://localhost:8000

### Notes for Windows users

- Run commands from this repository root in PowerShell or CMD.
- `./workspace` is bind-mounted into the container as `/workspace`, so `config.yaml`, `data.sqlite`, `session.session`, `media`, `site`, and other archive files persist on your Windows filesystem.
- The compose file includes `UID/GID` mapping mainly for Linux file-permission convenience; Docker Desktop on Windows can use it as-is.
- To use a different site directory, set `TG_ARCHIVE_SITE_DIR` (for example `/workspace/my-other-site`) when running compose commands.

### Usage

1. `tg-archive --new --path=mysite` (creates a new site. `cd` into mysite and edit `config.yaml`).
1. `tg-archive --sync` (syncs data into `data.sqlite`).
  Note: First time connection will prompt for your phone number + a Telegram auth code sent to the app. On successful auth, a `session.session` file is created. DO NOT SHARE this session file publicly as it contains the API autorization for your account.
1. `tg-archive --build` (builds the static site into the `site` directory, which can be published)

### Customization
Edit the generated `template.html` and static assets in the `./static` directory to customize the site.

### Note
- The sync can be stopped (Ctrl+C) any time to be resumed later.
- Setup a cron job to periodically sync messages and re-publish the archive.
- Downloading large media files and long message history from large groups continuously may run into Telegram API's rate limits. Watch the debug output.

Licensed under the MIT license.
