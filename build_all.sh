#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_all.sh — Generate business cards for all option combinations
#
# Produces 8 PDFs (2 bleed × 2 lang × 2 format) in the output/ directory.
# Requires: pdflatex (with standalone, tikz, fontawesome5, pdfx, helvet, etc.)
#
# Usage:
#   ./build_all.sh              # build all combinations
#   ./build_all.sh --clean      # remove output/ and aux files, then build
# ─────────────────────────────────────────────────────────────────────────────

TEXFILE="main"
OUTDIR="output"
AUXDIR=".aux"
ERRORS=0

# ── Parse arguments ──────────────────────────────────────────────────────────
if [[ "$1" == "--clean" ]]; then
  echo "Cleaning previous build..."
  rm -rf "$OUTDIR" "$AUXDIR"
fi

mkdir -p "$OUTDIR" "$AUXDIR"

# ── Card format dimensions ───────────────────────────────────────────────────
declare -A CARD_W=( [US]="88.9" [EU]="85" )
declare -A CARD_H=( [US]="50.8" [EU]="55" )

# ── Option combinations ──────────────────────────────────────────────────────
BLEEDS=(true false)
LANGS=(EN IT)
FORMATS=(US EU)

# ── Helper: compile one combination ─────────────────────────────────────────
compile() {
  local bleed="$1"   # true | false
  local lang="$2"    # EN | IT
  local fmt="$3"     # US | EU

  local cw="${CARD_W[$fmt]}"
  local ch="${CARD_H[$fmt]}"

  local bleedtag
  [[ "$bleed" == "true" ]] && bleedtag="bleed" || bleedtag="nobleed"
  local outname="card_${fmt}_${lang}_${bleedtag}"
  local logfile="${AUXDIR}/${outname}.log"

  echo "  Building: ${outname}.pdf ..."

  # Pass all options as \def before \input{main}
  # \USCard/\EUCard are NOT called here — we set \cardW and \cardH directly
  local defs="\def\withbleed{${bleed}}\def\lang{${lang}}\def\backstyle{minimal}\def\cardW{${cw}}\def\cardH{${ch}}\input{${TEXFILE}}"

  # Run pdflatex twice for stable multi-page standalone output
  for pass in 1 2; do
    pdflatex \
      -interaction=nonstopmode \
      -halt-on-error \
      -jobname="${outname}" \
      -output-directory="${AUXDIR}" \
      "${defs}" \
      > "$logfile" 2>&1
    local ret=$?
    if [[ $ret -ne 0 ]]; then
      echo "  ERROR: pdflatex failed on pass ${pass} for ${outname}"
      echo "  Last 20 lines of log:"
      tail -20 "$logfile" | sed 's/^/    /'
      ERRORS=$((ERRORS + 1))
      return 1
    fi
  done

  # Move final PDF to output/
  if [[ -f "${AUXDIR}/${outname}.pdf" ]]; then
    mv "${AUXDIR}/${outname}.pdf" "${OUTDIR}/${outname}.pdf"
    echo "  → ${OUTDIR}/${outname}.pdf  ✓"
  else
    echo "  ERROR: PDF not found after compilation for ${outname}"
    ERRORS=$((ERRORS + 1))
  fi
}

# ── Main loop ────────────────────────────────────────────────────────────────
echo ""
echo "Building all business card combinations..."
echo "──────────────────────────────────────────"

for bleed in "${BLEEDS[@]}"; do
  for lang in "${LANGS[@]}"; do
    for fmt in "${FORMATS[@]}"; do
      compile "$bleed" "$lang" "$fmt" || true
    done
  done
done

echo "──────────────────────────────────────────"
if [[ $ERRORS -eq 0 ]]; then
  echo "Done. All PDFs are in ./${OUTDIR}/"
  echo ""
  ls -lh "${OUTDIR}/"
else
  echo "Done with ${ERRORS} error(s). Check logs in ./${AUXDIR}/*.log"
  echo ""
  ls -lh "${OUTDIR}/" 2>/dev/null || echo "(no PDFs generated)"
fi
