#!/bin/bash
mkdir -p bashutils/usr/local/bin && cp src/shell/*.sh bashutils/usr/local/bin
dpkg-deb --build bashutils