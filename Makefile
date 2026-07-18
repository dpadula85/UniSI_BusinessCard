# ─────────────────────────────────────────────────────────────────────────────
# Makefile — Business card build system
#
# Usage examples:
#   make                        # build all 8 combinations
#   make clean                  # remove output/ and .aux/
#   make card FORMAT=US LANG=EN BLEED=true
#   make all_formats            # all formats, EN, with bleed
#   make all_langs              # all languages, US, with bleed
#   make print                  # all bleed variants (print-ready)
#   make preview                # all nobleed variants (screen preview)
# ─────────────────────────────────────────────────────────────────────────────

# ── Defaults ─────────────────────────────────────────────────────────────────
FORMAT   ?= US
LANG     ?= EN
BLEED    ?= true
BACKSTYLE ?= minimal

# ── Derived names ─────────────────────────────────────────────────────────────
BLEEDTAG  = $(if $(filter true,$(BLEED)),bleed,nobleed)
OUTNAME   = card_$(FORMAT)_$(LANG)_$(BLEEDTAG)
OUTDIR    = output
AUXDIR    = .aux

# ── Card dimensions ───────────────────────────────────────────────────────────
CARD_W_US = 88.9
CARD_H_US = 50.8
CARD_W_EU = 85
CARD_H_EU = 55
CARD_W    = $(CARD_W_$(FORMAT))
CARD_H    = $(CARD_H_$(FORMAT))

# ── pdflatex command ──────────────────────────────────────────────────────────
DEFS = \def\withbleed{$(BLEED)}\def\lang{$(LANG)}\def\backstyle{$(BACKSTYLE)}\def\cardW{$(CARD_W)}\def\cardH{$(CARD_H)}\input{main}
LATEX = pdflatex -interaction=nonstopmode -halt-on-error \
        -jobname="$(OUTNAME)" -output-directory="$(AUXDIR)"

# ─────────────────────────────────────────────────────────────────────────────
# Targets
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: all card print preview all_formats all_langs clean help

## all: build all 8 combinations
all:
	@bash build_all.sh

## card: build one specific card (use FORMAT=, LANG=, BLEED=)
card: $(OUTDIR)
	@echo "Building $(OUTNAME).pdf ..."
	@mkdir -p $(AUXDIR)
	@$(LATEX) "$(DEFS)" > $(AUXDIR)/$(OUTNAME).log 2>&1 || \
		(tail -20 $(AUXDIR)/$(OUTNAME).log; exit 1)
	@$(LATEX) "$(DEFS)" >> $(AUXDIR)/$(OUTNAME).log 2>&1 || \
		(tail -20 $(AUXDIR)/$(OUTNAME).log; exit 1)
	@mv $(AUXDIR)/$(OUTNAME).pdf $(OUTDIR)/$(OUTNAME).pdf
	@echo "→ $(OUTDIR)/$(OUTNAME).pdf  ✓"

## print: all bleed variants (print-ready, 4 PDFs)
print: $(OUTDIR)
	@$(MAKE) card FORMAT=US LANG=EN BLEED=true
	@$(MAKE) card FORMAT=US LANG=IT BLEED=true
	@$(MAKE) card FORMAT=EU LANG=EN BLEED=true
	@$(MAKE) card FORMAT=EU LANG=IT BLEED=true

## preview: all nobleed variants (screen preview, 4 PDFs)
preview: $(OUTDIR)
	@$(MAKE) card FORMAT=US LANG=EN BLEED=false
	@$(MAKE) card FORMAT=US LANG=IT BLEED=false
	@$(MAKE) card FORMAT=EU LANG=EN BLEED=false
	@$(MAKE) card FORMAT=EU LANG=IT BLEED=false

## all_formats: US and EU, current LANG and BLEED
all_formats: $(OUTDIR)
	@$(MAKE) card FORMAT=US
	@$(MAKE) card FORMAT=EU

## all_langs: EN and IT, current FORMAT and BLEED
all_langs: $(OUTDIR)
	@$(MAKE) card LANG=EN
	@$(MAKE) card LANG=IT

## clean: remove generated files
clean:
	@echo "Cleaning..."
	@rm -rf $(OUTDIR) $(AUXDIR)
	@echo "Done."

$(OUTDIR):
	@mkdir -p $(OUTDIR)

## help: show this message
help:
	@echo ""
	@echo "Usage:"
	@grep -E '^## ' Makefile | sed 's/## /  make /'
	@echo ""
	@echo "Options (with defaults):"
	@echo "  FORMAT=$(FORMAT)    US | EU"
	@echo "  LANG=$(LANG)      EN | IT"
	@echo "  BLEED=$(BLEED)  true | false"
	@echo ""
