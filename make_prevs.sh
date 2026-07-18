#!/usr/bin/env bash

# 1 — Build the required PDFs
make card FORMAT=US LANG=EN BLEED=false BACK=same
make card FORMAT=US LANG=EN BLEED=false BACK=mirror
make card FORMAT=US LANG=EN BLEED=false BACK=minimal

# 2 — Create docs/ folder
mkdir -p docs

# 3 — Extract pages to PNG (300 DPI)
# Each PDF has 2 pages: page 1 = front, page 2 = back
pdftoppm -r 300 -png output/card_US_EN_same_nobleed.pdf    /tmp/card_same
pdftoppm -r 300 -png output/card_US_EN_mirror_nobleed.pdf  /tmp/card_mirror
pdftoppm -r 300 -png output/card_US_EN_minimal_nobleed.pdf /tmp/card_minimal

# 4 — Copy to docs/ with the right names
# Front is the same in all — just take it from one
cp /tmp/card_minimal-1.png docs/front_US.png
cp /tmp/card_same-2.png    docs/back_same_US.png
cp /tmp/card_mirror-2.png  docs/back_mirror_US.png
cp /tmp/card_minimal-2.png docs/back_minimal_US.png
