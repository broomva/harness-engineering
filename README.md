# harness-engineering (DEPRECATED — migrated to the broomva/skills monorepo)

> **Status:** 6-month deprecation window (until 2026-12-27). This skill now lives in the
> [broomva/skills](https://github.com/broomva/skills) monorepo (BRO-1561 / BRO-1570).

## New install

```bash
npx skills add broomva/skills --skill harness-engineering-playbook
```

The skill content remains under `skills/harness-engineering-playbook/` in the monorepo. The old
`npx skills add broomva/harness-engineering` continues to resolve through the deprecation window,
but new installs should use the command above (the monorepo layout fixes the
remote root-install script-drop hazard, vercel-labs/skills#1523).
