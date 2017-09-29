# bigdirs

> Bash script to find big directories (>1GB).

<img src="./screenshot.png" width="340" />

# Install

```bash
wget https://raw.githubusercontent.com/miguelmota/bigdirs/master/bigdirs.sh
chmod +x bigdirs.sh
mv bigdirs.sh /usr/local/bin/bigdirs
```

# Usage

```bash
$ bigdirs [flags] {path}
```

# Example

Standard example

```bash
$ bigdirs ~/
```

<img src="./screenshot_standard.gif" width="340" />

Verbose example

```bash
$ bigdirs -v ~/
```

<img src="./screenshot_verbose.gif" width="340" />

Verbose and exhaustive example (shows all big directories recursively)

```bash
$ bigdirs -v -e ~/
```

<img src="./screenshot_exhaustive.gif" width="340" />

# FAQ

- Q: I'm getting a `Permission denied` error!

  - A: Try running as root user with `sudo` to scan permission restricted directories.

# License

MIT
