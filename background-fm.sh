#!/bin/bash

| grep '<image size="extralarge"' | sed -r 's/<\/?\w(\w|| )+(="\w+")?>//g' | sed 's/ //g'
