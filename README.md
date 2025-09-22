# Obscura VM

A hard-level Ubuntu-based CTF machine with chained SSRF, LFI, MariaDB abuse, Docker pivoting, and rabbit holes.

## Exploit Path

1. SSRF via Flask redirect → internal API
2. LFI leaks `.env.b64` → decode DB creds
3. MariaDB `FILE` privilege → write reverse shell
4. Cronjob triggers shell → user access
5. Docker group → mount host → root

## Rabbit Holes

- SUID binary `/usr/bin/oldbackup`
- Cronjob `/usr/local/bin/rotate.sh`
- Fake `.git` repo
- Decoy `.env` file
- Spoofed Apache banner
- SSH banner with fake flag

## Default Credentials

- Username: `webuser`
- Password: `webpass`
