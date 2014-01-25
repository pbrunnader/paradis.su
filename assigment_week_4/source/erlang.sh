#!/bin/bash

filename=$(basename "$1")
extension="${filename##*.}"
filename="${filename%.*}"

rm *.beam *.dump 2>/dev/null
erlc *.erl
erl -noshell -s $filename start -s init stop