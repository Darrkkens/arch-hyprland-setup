#!/bin/bash

pidof hyprlock >/dev/null && exit 0

hyprlock