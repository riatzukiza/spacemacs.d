# PROCESS — spacemacs.d

Mini charter, epiphany-modeled.

## Loop

1. **Observe** — reproduce against the live daemon; warnings in
   `*Messages*` / init logs / `journalctl --user -u emacs` are the primary
   signal.
2. **Model** — decide which file owns the change (layer vs `config/` vs
   `core/`); check the blast radius against the bootstrap order.
3. **Change** — smallest edit that satisfies the invariants in AGENTS.md.
4. **Verify** — byte-compile + `make test`; restart the daemon and confirm
   the manual gate (unit active + `emacsclient` answers) when startup was
   touched.
5. **Record** — commit on `device/stealth` with explicit adds; log known-
   but-unfixed warnings as Status entries rather than leaving them silent.

## Rules of thumb

- Config that only a running Emacs can disprove must be verified against the
  running Emacs (gate, byte-compile, ERT) before being called done.
- Device-branch work stays device-branch: merge `origin/main` into
  `device/stealth`; never drift onto other branches.
- Full process details live in the epiphany charter (verified present on
  this device):
  [../spaces/foresight/epiphany/PROCESS.md](../spaces/foresight/epiphany/PROCESS.md)
