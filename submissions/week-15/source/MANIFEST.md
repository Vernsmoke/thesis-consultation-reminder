# Week 15 Source Manifest

Status: **working-tree preparation record; not a confirmed source snapshot**.

- Baseline commit: `133b0c8` on `master`.
- Week 15 source/tests/evidence were verified on 2026-11-08 Asia/Manila while uncommitted.
- Intended milestone tag: `v3.0.0`, to be created by the user only after the reviewed commits.
- No source ZIP is created yet because copying the current tree and labeling it as the milestone would misstate provenance.

After the user confirms the final source commit, create an ignored archive from that exact commit and exclude `.git`, `vendor`, `.dart_tool`, build/cache output, live `.env`, storage secrets/keyrings/private TLS keys, private fixture values, temporary renders, real data, and submission archives. Preserve lockfiles, migrations, seeders with fictional data, `.env.example`, controlled tests, and run instructions. Record the confirmed commit/tag, entry count, creation time, and SHA-256 here before packaging the final submission.
