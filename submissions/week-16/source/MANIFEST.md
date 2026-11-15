# Week 16 Source Manifest

The Week 16 revision is based on verified Week 15 tag `v3.0.0` at `134077c9a7ef13dd607c0bc763c80989144fe9bb`. The implementation and report checkpoint is `e93f9a59be4628b77e19aa530dd818e278dd66b1`; the annotated `v4.0.0` release tag will include this checkpoint plus the provenance handoff. Week 16 source changes are limited to readiness/configuration, tests/evaluation tools, documentation and evidence. No migration or workflow feature was added.

Create the final source archive from the verified `v4.0.0` tag. Exclude `.git`, `backend/.env`, `backend/vendor`, `backend/storage/app/private`, `frontend/.dart_tool`, `frontend/build`, logs with private values, dependencies, caches and earlier temporary QA folders. Preserve lockfiles, migrations, seeders, `.env.example`, the Week 16 scripts and controlled evidence.
