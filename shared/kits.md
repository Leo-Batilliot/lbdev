# lbdev kits

A kit is know-how a role reads on demand (for example how to draw readable diagrams). Kits live in `<plugin-root>/kits/` and are listed in `<plugin-root>/kits/index.md`. Each role may use at most `max_kits_per_role` kits (given by the command that loaded this file).

## Loading

When you dispatch a role, or act as one yourself, look up the kits listed for that role in `kits/index.md` and tell it to read them first. Then append one line per kit read to `<plugin-data>/kits-usage.log`: `<YYYY-MM-DD> <kit name> <role>`.

## Finding

1. Write the need in one line: which role, what know-how, for what kind of output.
2. Check `kits/index.md`: if a kit already covers the need, stop there.
3. Dispatch one scout (standard tier) with the need.
4. Dispatch one skill-auditor (heavy tier) per candidate, in parallel, with the candidate's URL and version, the need, and the content of `kits/index.md`.
5. Report as a table: candidate, verdict, license, security, fit, overlap. Recommend one, or none.

Never integrate a candidate the auditor rejected. Never run a candidate's scripts.

## Integrating (after the user chose)

The user chooses, except in `/lbdev:plan` with autonomy `auto`, where the command's own rules decide which audited candidates enter. `/lbdev:kits` always asks: you run it to choose.

1. Find the plugin source as `/lbdev:improve` does (the `source_dir` setting, or the plugin root when it is a source checkout). Without an editable source, stop and say so.
2. Write `kits/<name>.md` from the auditor's proposed kit. Start it with:

```
<!-- kit: <name> | source: <url> | version: <commit or tag> | license: <license> | audited: <YYYY-MM-DD> | changes: <none or one line> -->
```

3. Keep the original license notice when the license requires it.
4. Scripts are copied only if the user explicitly accepted them, after the auditor read them.
5. Add or update the entry in `kits/index.md`, with an `approved:` line: `user` or `auto (skill-auditor)`. When a role would exceed its kit limit, ask the user which kit to replace. A kit that covers the same need as an existing one replaces it instead of being added.
6. Do not edit role files to mention the kit: roles find their kits through the registry.
7. Run `bash "<plugin source>/tests/run.sh"` and bump the minor version in `.claude-plugin/plugin.json`.

## Pruning

Read `<plugin-data>/kits-usage.log`. Propose removing kits not used for 90 days, and kits whose need another kit now covers. Remove only what the user confirms.

## Checking for updates

For each external kit, compare the pinned version with the source's latest. When it changed, dispatch a skill-auditor on the difference only, and propose the update with its verdict.
