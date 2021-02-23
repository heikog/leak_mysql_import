#!/bin/bash
for f in *.tar.gz; do tar --skip-old-files -xvf "$f"; done
