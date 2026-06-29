# TKG Custom AI-Named SuperTuxKart Image

This branch is intentionally separate from `main` and does **not** replace the stable GSA image or its marketplace blueprint.

## Separate image

The custom GitHub Container Registry tag is:

```text
ghcr.io/twistedbobross/supertuxkart-gsa-windows:custom-ai-names
```

The `custom-ai-names` branch builds this image from SuperTuxKart 1.5 source, changes the server-side network AI display names, and publishes the image only after the workflow succeeds.

## Separate blueprint

Import this branch-local blueprint into GSA only after the custom image tag has been published:

```text
blueprints/supertuxkart-gsa-windows-custom-ai-names.json
```

It uses the separate `custom-ai-names` image tag. The original blueprint and its `1.5-ltsc2022-x86_64-r8` image remain unchanged on `main`.

## First ten local AI racer names

These are character-style names inspired by TKG and its Ark, Conan, Palworld, Valheim, Fibercraft, and SuperTuxKart communities. They are deliberately **not** copies of server names.

1. Tekwhisker — Tek / Ark inspiration
2. Obelisk Outlaw — Ark obelisk inspiration
3. Raptor Rumbler — Ark creature/racing inspiration
4. Cimmerian Claw — Conan Exiles inspiration
5. Paldust Pouncer — Palworld inspiration
6. Runeclaw Rider — Valheim rune/saga inspiration
7. Yggdrift — Valheim world-tree/racing inspiration
8. Frostmead Fury — Valheim biome/mead inspiration
9. Fiberfang — Twisted Fibers / Fibercraft inspiration
10. Tux Turbo — SuperTuxKart and TKG inspiration

When **AI Racers** is greater than ten, additional racers are named `TKG Racer 11`, `TKG Racer 12`, and so on.

## Deployment notes

- Set **AI Handling** to `true` and **AI Racers** to at least `1`.
- Keep the original image available as a rollback path while testing.
- Recreate/reinstall the GSA server after changing the image tag so Docker pulls the custom image.
- This is a source-built custom STK binary, so use it as a private/test deployment until its GitHub Actions build and an in-game lobby test both succeed.
