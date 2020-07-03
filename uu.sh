#!/bin/bash

## Variables

assume_yes=false

## Functions

function uu::headline ()
{
  echo
  echo "$(tput setab 2)$(tput bold)$1:$(tput sgr0)"
  echo
}

function uu::unavailable ()
{
  uu::headline "$1"
  echo
  echo "$(tput setab 3)$1 is not installed, skipping$(tput sgr0)"
  echo
}

function uu::uptodate ()
{
  uu::headline "$1"
  echo
  echo "$(tput setab 2)All $1 packages are already up-to-date, skipping$(tput sgr0)"
  echo
}

function uu::run ()
{
  if command -v "$1" > /dev/null;
  then
    uu::headline "$1"
    eval "$2"
  else
    uu::unavailable "$1"
  fi
}

function uu::apt ()
{
  if [[ "$assume_yes" = true ]]; then
    uu::run "apt" "sudo apt update && sudo apt upgrade -y"
  else
    uu::run "apt" "sudo apt update && sudo apt upgrade"
  fi
}

function uu::flatpak ()
{
  if [[ "$assume_yes" = true ]]; then
    uu::run "flatpak" "flatpak update -y"
  else
    uu::run "flatpak" "flatpak update"
  fi
}

function uu::homebrew ()
{
  brew update > /dev/null
  if command -v "brew outdated" > /dev/null
  then
    uu::run "brew" "brew upgrade"
  else
    uu::uptodate "brew"
  fi
}

function uu::composer ()
{
  uu::run "composer" "composer selfupdate"
}

## Script

case "$1" in
	-v) echo "verbose option passed (TODO)" ;;
	-y) assume_yes=true ;;
	--)
		shift ;;

	*) echo "Option $1 not recognized" ;;

esac

echo

uu::apt
uu::flatpak
uu::homebrew
uu::composer
