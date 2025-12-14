#!/usr/bin/env powershell

param(
  [Parameter(Mandatory, Position=0)]
  [string]$Name,

  [Parameter(Position=1, ValueFromRemainingArguments)]
  [string[]]$Remaining
)

& flutter pub run fastforge:main release --name $Name --skip-clean --no-version-check @Remaining
