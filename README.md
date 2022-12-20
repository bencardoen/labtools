# A set of adminstration tools to make working with remote *nix systems easier

## What to find where
```bash
repository
├── scripts
│   ├── compress.h      # Parallel tar + compress
│   ├── remotemount.sh  # Use SSHFS to mount remote directories (and remount on failure)
```

## Usage
Note that these are scripts, so they need execute permissions:
```bash
chmod u+x script.sh
```
### Compress.sh
#### Dependencies
This requires [pigz](https://zlib.net/pigz/), the parallel version of gzip, and tar, which most linux systems have.
E.g. to install on Red Hat based systems
```bash
sudo dnf install pigz tar
```
#### Usage
```bash
compress.sh /data/to/compress archive.tgz <nrofcpus> [exclude pattern]
```
For example, to compress with 24 cores but skip all tif files:
```bash
compress.sh /data/to/compress archive.tgz 24 *.tif
```
To compress everything
```bash
compress.sh /data/to/compress archive.tgz 24
```
If you want to find out how many cores you have on your system
```bash
NCPU=`cat /proc/cpuinfo | grep processor | wc -l `
echo $NCPU
```
### remotemount.sh
Suppose you have access (with SSH) to a cluster, and you want to browse selected files from a large dataset, edit a few files, etc.
In this case sync/copy tools are overkill, you can instead mount the remote files so they appear to your local machine as if they are a local folder:
```
[you] -- SSHFS -- [remotesystem/path/to/files]
```
#### Dependencies
This requires
- SSH (key based) access, please see documentation for your remote system
- SSHFS
On Red Hat based systems, you can install sshfs by
```bash
sudo dnf install fuse-sshfs
```
#### Usage
A mountpoint should be an empty directory, once mounted, that directory will show remote data.
For example, say your mountpoint is `/home/me/mount`, and your remote machine is `remote.server.com:/home/me`.
```bash
./remotemount.sh remote.server.com:/home/me /home/me/mount
```
And that's it, your remote folder will now act as a local folder, you can browse, edit etc.
To unmount, do:
```bash
./remotemount.sh /home/me/mount
```
##### Notes
- The options are tweaked for my usage, but for collaborative editing you may want to change the cache timing.
- This reconnects, so even on a laptop when it hibernates and you go to a new wifi access point, it will reconnect.
- This can work on Mac/Cygwin, but I have neither, so if it breaks, make a PR/issue.
