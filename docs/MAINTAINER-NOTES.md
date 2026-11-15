# Maintainer notes

Written by Claude (AI) at the end of the initial build-out, 2026-11-16. For
future maintainers, human or AI, who start without the original conversation.

## Established facts (AS6704T, ADM 4.3.3.RY62)

- `uname -r` is the literal string `5.13.x`. The source Makefile says
  `SUBLEVEL = x`, `TRUESUBLEVEL = 19`.
- vermagic is `5.13.x SMP mod_unload modversions` followed by one trailing
  space. The space is not a copy error: the kernel builds the string from
  components that each end with a space (`include/linux/vermagic.h`). Compare
  vermagic values with trailing whitespace trimmed.
- `CONFIG_MODVERSIONS=y`, `CONFIG_MODULE_SIG` unset, `CONFIG_DEBUG_INFO=y`.
- `/proc/config.gz` exists. Use it instead of the vendor `.config`, which
  differs in NFS and Android binder options.
- The kernel is built by a daily-build host with
  `x86_64-asustor_x64_g3_2020.12.24-linux-gnu-gcc` 7.4.0, the same toolchain
  ASUSTOR publishes.
- Coral Edge TPU PCI ID is `1ac1:089a`.
- Userland is BusyBox: `lspci` has no `-s`, `modinfo` cannot dump symbol
  versions, `insmod` errors are generic. Read `dmesg` for the real reason.

## Source quirks

- The kernel tarball is named `.tar.bz2` but is XZ-compressed. Use `tar -xf`.
- SourceForge needs the `/download` suffix and is slow (about 8 minutes for
  125 MB from a GitHub runner).
- The published source lacks three built-in vendor drivers present on the
  NAS: `R8125`, `R8168`, `VIRMOUSE`. This did not affect the modules.
- Upstream `google/gasket-driver` is archived. Its `main` builds on 5.13
  without patches. Kernel 6.4+ would need a patched fork.

## Build facts

- `CONFIG_MODVERSIONS=y` requires a full kernel build for `Module.symvers`.
  It takes about 12 minutes on a free runner, about 24 minutes in total.
- Unstripped modules are 1.5 MB and 470 KB because of `CONFIG_DEBUG_INFO`.
  The artifact ships them with `strip --strip-debug`.

## CI failures encountered

1. A `file | grep bzip2` guard failed because the tarball is XZ.
2. An exact vermagic comparison failed because of the trailing space.
3. The download cache is saved only when a job succeeds, so failed runs
   re-download.

## Reading CI without credentials

For a public repo the unauthenticated GitHub API returns run status, job
steps, annotations and finished job logs. Logs of a running job return 404.

## Verification on the NAS

Passed on 2026-11-16: modules load at boot, `/dev/apex_0` present, `status`
is `ALIVE`, `temp` readable, 13 MSI-X vectors, link 5.0 GT/s x1, Frigate in
Docker starts its Edge TPU detector.

A module built for another kernel fails with
`disagrees about version of symbol module_layout`.

## Lessons

- The feared symbol CRC mismatch did not occur, although the published
  source (2026-06-11) predates the NAS kernel build (2026-08-11).
- A kernel build date later than the source date proves nothing by itself:
  the daily build recompiles unchanged source.
- A CRC mismatch is rejected before module code runs. Trying `insmod` is
  safe and cheaper than elaborate pre-verification.
- ADM build codes appear to encode the build date (letter for month,
  character for day). This is inferred, not documented.

## Supporting a new ADM build

1. Owner exports `/proc/config.gz` and reports `uname -r`, `uname -v` and the
   vermagic of a stock module.
2. Add `config/adm-<build>.config`.
3. Check SourceForge for a newer tarball and update the name and SHA-1.
4. Run the workflow, then have the owner load and verify.

## Releases

A successful build on `main` publishes a GitHub release with the module
tarball. The workflow does this itself with the run's `GITHUB_TOKEN`; no
personal token or paid resource is involved. Only the build tested by the
owner is hardware-verified (see README); later releases are rebuilt from the
same sources but are not individually tested.

## Constraints at the time of writing

- The AI session could not reach SourceForge or the NAS, could not create
  repositories, and had no GitHub API token. It could only `git push`, so it
  cannot create pull requests or edit releases directly.
- Owner rules are in `CLAUDE.md`.

## Open items

- `gasket_ref` defaults to `main`. Pin it to the commit recorded in
  `BUILD_INFO`.
- The device node is `root:root 0660`. Non-root containers are not handled.
- GitHub warns that `actions/checkout@v4` and `actions/cache@v4` target a
  deprecated Node.js version.
- ADM 5 (kernel 6.6) and ARM64 models are not covered.
