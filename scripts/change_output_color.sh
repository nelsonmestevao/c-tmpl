#!/bin/bash

TYPE=0

case $1 in
black)
  COLOR=30
  ;;
red)
  COLOR=31
  ;;
green)
  COLOR=32
  ;;
yellow)
  COLOR=33
  ;;
blue)
  COLOR=34
  ;;
magenta)
  COLOR=35
  ;;
cyan)
  COLOR=36
  ;;
white)
  COLOR=37
  ;;
esac

case $2 in
bold | bright)
  TYPE=1
  ;;
underline)
  TYPE=4
  ;;
inverse)
  TYPE=7
  ;;
reset | *)
  TYPE=0
  ;;
esac

echo -en "\033[${TYPE};${COLOR}m"
