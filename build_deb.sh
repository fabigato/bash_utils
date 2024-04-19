#!/bin/bash
cp src/shell/*.sh bashutils/usr/local/bin
dpkg-deb --build bashutils