#!/usr/bin/env bash

pmset -g batt | grep -o "\d\d%"
