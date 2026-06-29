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

1. Whiskers Ascended — Ark Survival Ascended PvE
2. Twisted Purrgatory — Ark Survival Ascended PvP
3. Kitten Colony — Ark Survival Ascended Lost Colony
4. Frayed Reach — Chronicles of Twisted Fibers
5. Exiles of TKG — Conan Exiles
6. Twisted Pals — Palworld
7. Echoes of Valheim — Valheim
8. Shadows of Valheim — Valheim
9. Twisted Fibers — Fibercraft community
10. TKG Turbo Tux — SuperTuxKart / Twisted Kittens Gaming

When **AI Racers** is greater than ten, additional racers are named `TKG Racer 11`, `TKG Racer 12`, and so on.

## Deployment notes

- Set **AI Handling** to `true` and **AI Racers** to at least `1`.
- Keep the original image available as a rollback path while testing.
- Recreate/reinstall the GSA server after changing the image tag so Docker pulls the custom image.
- This is a source-built custom STK binary, so use it as a private/test deployment until its GitHub Actions build and an in-game lobby test both succeed.
