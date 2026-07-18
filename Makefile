# ─────────────────────────────────────────────────────────────────────────────
# Makefile — Business card build system
#
# Usage examples:
#   make                                        # build all 24 combinations
#   make clean                                  # remove output/ and .aux/
#   make card FORMAT=US LANG=EN BLEED=true BACK=minimal
#   make print                                  # all bleed variants (12 PDFs)
#   make preview                                # all nobleed variants (12 PDFs)
#   make all_formats LANG=EN BLEED=true BACK=minimal
#   make all_langs   FORMAT=US BLEED=true BACK=minimal
#   make all_backs   FORMAT=US LANG=EN BLEED=false
# ─────────────────────────────────────────────────────────────────────────────

# ── Defaults ──────────────────────────────────────────────────────────────────
FORMAT ?= US
LANG   ?= EN
BLEED  ?= true
BACK   ?= minimal

# ── Derived names ─────────────────────────────────────────────────────────────
BLEEDTAG = $(if $(filter true,$(BLEED)),bleed,nobleed)
OUTNAME  = card_$(FORMAT)_$(LANG)_$(BACK)_$(BLEEDTAG)
OUTDIR   = output
AUXDIR   = .aux

# ── Card dimensions ───────────────────────────────────────────────────────────
CARD_W_US = 88.9
CARD_H_US = 50.8
CARD_W_EU = 85
CARD_H_EU = 55
CARD_W    = $(CARD_W_$(FORMAT))
CARD_H    = $(CARD_H_$(FORMAT))

# ── pdflatex invocation ───────────────────────────────────────────────────────
DEFS  = \def\withbleed{$(BLEED)}\def\lang{$(LANG)}\def\backstyle{$(BACK)}\def\cardW{$(CARD_W)}\def\cardH{$(CARD_H)}\input{main}
LATEX = pdflatex -interaction=nonstopmode -halt-on-error \
        -jobname="$(OUTNAME)" -output-directory="$(AUXDIR)"

# ─────────────────────────────────────────────────────────────────────────────
# Targets
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: all card print preview all_formats all_langs all_backs clean help

## all: build all 24 combinations
all:
	@bash build_all.sh

## card: build one specific card (use FORMAT=, LANG=, BLEED=, BACK=)
card: $(OUTDIR)
	@echo "Building $(OUTNAME).pdf ..."
	@mkdir -p $(AUXDIR)
	@$(LATEX) "$(DEFS)" > $(AUXDIR)/$(OUTNAME).log 2>&1 || \
		(tail -20 $(AUXDIR)/$(OUTNAME).log; exit 1)
	@$(LATEX) "$(DEFS)" >> $(AUXDIR)/$(OUTNAME).log 2>&1 || \
		(tail -20 $(AUXDIR)/$(OUTNAME).log; exit 1)
	@mv $(AUXDIR)/$(OUTNAME).pdf $(OUTDIR)/$(OUTNAME).pdf
	@echo "→ $(OUTDIR)/$(OUTNAME).pdf  ✓"

## print: all bleed variants (12 PDFs)
print: $(OUTDIR)
	@for fmt in US EU; do \
	  for lang in EN IT; do \
	    for back in same mirror minimal; do \
	      $(MAKE) -s card FORMAT=$$fmt LANG=$$lang BLEED=true BACK=$$back; \
	    done; \
	  done; \
	done

## preview: all nobleed variants (12 PDFs)
preview: $(OUTDIR)
	@for fmt in US EU; do \
	  for lang in EN IT; do \
	    for back in same mirror minimal; do \
	      $(MAKE) -s card FORMAT=$$fmt LANG=$$lang BLEED=false BACK=$$back; \
	    done; \
	  done; \
	done

## all_formats: US and EU, with current LANG, BLEED, BACK
all_formats: $(OUTDIR)
	@$(MAKE) -s card FORMAT=US
	@$(MAKE) -s card FORMAT=EU

## all_langs: EN and IT, with current FORMAT, BLEED, BACK
all_langs: $(OUTDIR)
	@$(MAKE) -s card LANG=EN
	@$(MAKE) -s card LANG=IT

## all_backs: all 3 back styles, with current FORMAT, LANG, BLEED
all_backs: $(OUTDIR)
	@$(MAKE) -s card BACK=same
	@$(MAKE) -s card BACK=mirror
	@$(MAKE) -s card BACK=minimal

## previews: generate docs/ preview images for the README
previews:
	@bash make_prevs.sh

## clean: remove generated files
clean:
	@echo "Cleaning..."
	@rm -rf $(OUTDIR) $(AUXDIR)
	@echo "Done."

$(OUTDIR):
	@mkdir -p $(OUTDIR)

## help: show available targets and options
help:
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' Makefile | sed 's/## /  make /'
	@echo ""
	@echo "Options (current values):"
	@echo "  FORMAT=$(FORMAT)    US | EU"
	@echo "  LANG=$(LANG)      EN | IT"
	@echo "  BLEED=$(BLEED)  true | false"
	@echo "  BACK=$(BACK)  same | mirror | minimal"
	@echo ""
