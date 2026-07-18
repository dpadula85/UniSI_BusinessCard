# Business Card — LaTeX / TikZ template

A fully parametric LaTeX business card for the University of Siena, built with
TikZ. Supports multiple output configurations (language, card format, bleed)
controlled by a Makefile and build script.

---

## Repository structure

```
.
├── main.tex                   # Card source — do not edit personal data here
├── personal.tex               # ← YOUR DATA — gitignored, never committed
├── personal.tex.example       # Template to copy and fill in
├── build_all.sh               # Builds all 8 combinations
├── Makefile                   # Convenient build targets
├── imgs/
│   ├── UNISI_vert_col-_CMYK.pdf   # University logo (CMYK)
│   ├── skyline_UniSI_red.png      # Siena skyline (transparent PNG)
│   └── DP_qr/
│       └── qrcode.pdf             # QR code (UniRed on CardGray)
└── output/                    # Generated PDFs (created by build system)
```

---

## First-time setup

Personal data (name, email, phone, etc.) is stored in `personal.tex`, which
is **gitignored** and never committed to the repository.

```bash
cp personal.tex.example personal.tex
# then edit personal.tex with your details
```

---

## Building

### All combinations at once

```bash
make           # or: bash build_all.sh
```

Produces 8 PDFs in `output/`:

```
output/
├── card_US_EN_bleed.pdf      # US format, English, print-ready
├── card_US_EN_nobleed.pdf    # US format, English, screen preview
├── card_US_IT_bleed.pdf
├── card_US_IT_nobleed.pdf
├── card_EU_EN_bleed.pdf
├── card_EU_EN_nobleed.pdf
├── card_EU_IT_bleed.pdf
└── card_EU_IT_nobleed.pdf
```

### Specific combinations

```bash
# One specific card
make card FORMAT=US LANG=EN BLEED=true

# All print-ready variants (with bleed)
make print

# All screen preview variants (no bleed)
make preview

# Both formats, English, with bleed
make all_formats LANG=EN BLEED=true

# Both languages, US format, no bleed
make all_langs FORMAT=US BLEED=false

# Clean and rebuild everything
make clean && make
```

### Help

```bash
make help
```

---

## Output options

| Option | Values | Default | Description |
|---|---|---|---|
| `FORMAT` | `US` / `EU` | `US` | Card size |
| `LANG` | `EN` / `IT` | `EN` | Card language |
| `BLEED` | `true` / `false` | `true` | Bleed zone + crop marks |

### Card dimensions

| Format | Width | Height |
|---|---|---|
| US (North American standard) | 88.9 mm | 50.8 mm |
| EU (European standard) | 85 mm | 55 mm |

### Back face styles

Controlled by `\def\backstyle{...}` in `main.tex`:

| Style | Description |
|---|---|
| `same` | Identical to the front face |
| `mirror` | Same content, red panel on the right |
| `minimal` | Name + role + Siena skyline watermark |

---

## Bleed and print safety

When `BLEED=true`:
- All background fills extend **3 mm** beyond the card edge on every side.
- Crop marks are drawn **1 mm** outside the card edge, each **3 mm** long.
- The PDF page is larger than the card (card size + 2 × 3 mm on each axis).
- **Send this version to professional printers.**

When `BLEED=false`:
- The PDF page is exactly the card size, no crop marks.
- Use this for digital sharing or screen preview.

---

## Privacy

Personal data lives in `personal.tex` which is listed in `.gitignore`.
Only `personal.tex.example` (with placeholder values) is tracked by git.

This means:
- Your email, phone number and address are never pushed to GitHub.
- Anyone cloning the repo gets the template structure and can fill in their own
  data by copying `personal.tex.example` to `personal.tex`.

---

## QR code generation

The QR code is generated in Python with the `qrcode` and `reportlab` libraries,
coloured in UniRed (`#B00020`) on CardGray (`RGB 235, 235, 235`) background:

```python
import qrcode
from PIL import Image
from reportlab.pdfgen import canvas
from reportlab.lib.units import mm

qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_H,
                   box_size=40, border=1)
qr.add_data("https://your-url-here")
qr.make(fit=True)

card_gray = (235, 235, 235)
uni_red   = (176, 0, 32)

img = qr.make_image(fill_color="black", back_color="white").convert("RGBA")
img.putdata([uni_red + (255,) if px[0] < 50 else card_gray + (255,)
             for px in img.getdata()])
img.save("qrcode.png")

c = canvas.Canvas("qrcode.pdf", pagesize=(30*mm, 30*mm))
c.drawImage("qrcode.png", 0, 0, width=30*mm, height=30*mm)
c.save()
```

---

## Colors

| Name | CMYK | Hex (approx.) | Usage |
|---|---|---|---|
| `UniRed` | `(0, 1, 0.819, 0.310)` | `#B00020` | All text and accents |
| `CardGray` | `(0, 0, 0, 0.08)` | `#EBEBEB` | Gray panel background |

---

## Dependencies

Compiled with `pdflatex`. Required LaTeX packages:

- `tikz` + libraries `calc`, `positioning`
- `xcolor` (with `cmyk` option)
- `helvet`
- `graphicx`
- `fontawesome5`
- `standalone` (with `multi=tikzpicture`)
- `pdfx` (with `a-1b` option)

All packages are available in TeX Live, MiKTeX, and on Overleaf.

---

## License

The card layout and build scripts are released under the MIT License.
The UNISI logo and brand assets are property of the Università di Siena and
are used here for personal institutional purposes only — do not redistribute.
