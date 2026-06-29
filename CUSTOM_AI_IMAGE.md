# TKG Custom AI-Named SuperTuxKart Image

This branch is separate from `main` and does not replace the stable GSA image or its marketplace blueprint.

## Separate custom image package

The custom branch publishes a different GHCR package from the stable image:

```text
ghcr.io/twistedbobross/supertuxkart-gsa-windows-custom-ai:1.5-tkg-ai-names
```

This separate package is created and published by the `custom-ai-names` branch workflow using the repository's built-in `GITHUB_TOKEN`. It does not need access to the existing `supertuxkart-gsa-windows` package.

## Separate GSA blueprint

Use this branch-local blueprint after the custom image has published:

```text
blueprints/supertuxkart-gsa-windows-custom-ai-names.json
```

The blueprint references only the custom image package and leaves the image and blueprint on `main` unchanged.

## First ten local AI racer names

1. Tekwhisker
2. Obelisk Outlaw
3. Raptor Rumbler
4. Cimmerian Claw
5. Paldust Pouncer
6. Runeclaw Rider
7. Yggdrift
8. Frostmead Fury
9. Fiberfang
10. Tux Turbo

Any additional AI racers use numbered fallback names such as `TKG Racer 11`.

## GitHub build process

The branch workflow runs on GitHub's Windows runner, starts the Docker service, builds the custom Windows container, and pushes the two custom image tags. It uses `GITHUB_TOKEN` with `packages: write`, which GitHub supports for publishing packages associated with the workflow repository.

## Deployment notes

- Set **AI Handling** to `true` and **AI Racers** to at least `1`.
- Do not change the original GSA server or its stable image while testing this custom version.
- Create a separate GSA server from the custom blueprint after this image publishes.
