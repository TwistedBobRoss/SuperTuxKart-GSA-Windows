param(
    [Parameter(Mandatory = $true)]
    [string]$SourceFile
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceFile)) {
    throw "SuperTuxKart source file was not found: $SourceFile"
}

$old = @'
#ifdef SERVER_ONLY
            core::stringw name = L"Bot";
#else
            core::stringw name = _("Bot");
#endif
            name += core::stringw(" ") + StringUtils::toWString(i + 1);
'@

$new = @'
            static const wchar_t* const TKG_AI_NAMES[] =
            {
                L"Tekwhisker",
                L"Obelisk Outlaw",
                L"Raptor Rumbler",
                L"Cimmerian Claw",
                L"Paldust Pouncer",
                L"Runeclaw Rider",
                L"Yggdrift",
                L"Frostmead Fury",
                L"Fiberfang",
                L"Tux Turbo"
            };

            constexpr unsigned TKG_AI_NAME_COUNT =
                sizeof(TKG_AI_NAMES) / sizeof(TKG_AI_NAMES[0]);

            core::stringw name;
            if (i < TKG_AI_NAME_COUNT)
            {
                name = TKG_AI_NAMES[i];
            }
            else
            {
                name = L"TKG Racer ";
                name += StringUtils::toWString(i + 1);
            }
'@

$text = [System.IO.File]::ReadAllText($SourceFile)
if (-not $text.Contains($old)) {
    throw 'The expected STK Bot-name block was not found. Review the upstream 1.5 source before rebuilding.'
}

$updated = $text.Replace($old, $new)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($SourceFile, $updated, $utf8NoBom)

Write-Host 'Applied TKG custom network-AI racer names.'
