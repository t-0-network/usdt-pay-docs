#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="integration-guidance/api-reference"
TEMPLATE="$SCRIPT_DIR/gen-doc-template.tmpl"
PROTO_DIR="$PROJECT_DIR/proto"

# Replicate protoc-gen-doc's anchor filter: "/" -> "_", other special chars -> "-"
anchor_filter() {
    local str="$1"
    str="${str//\//_}"
    echo "$str" | sed 's/[^a-zA-Z0-9_-]/-/g'
}

escape_sed() {
    printf '%s' "$1" | sed 's/[&|\\]/\\&/g'
}

# Pages to generate: "proto_file|title|weight|slug"
# The fourth column is the output slug (md filename and Hugo URL segment).
# validate.proto is proto2 extensions only — protoc resolves it via --proto_path
# but it has nothing the template renders, so it is not listed here.
PAGES=(
    "tzero/v1/pay/acquirer/acquirer.proto|Acquirer|331|pay_acquirer"
    "tzero/v1/pay/issuer/issuer.proto|Issuer|332|pay_issuer"
    "tzero/v1/pay/lp/lp.proto|Liquidity Provider|333|pay_lp"
    "tzero/v1/pay/common.proto|Shared Types|337|pay_common"
)

# Derive ALL_PROTOS from PAGES (single source of truth)
ALL_PROTOS=()
for page in "${PAGES[@]}"; do
    IFS='|' read -r proto _ _ _ <<< "$page"
    ALL_PROTOS+=("$proto")
done

# Build FILEREF sed script: maps anchor(file.Name) -> ../slug/
FILEREF_SED_SCRIPT=$(mktemp)
for page in "${PAGES[@]}"; do
    IFS='|' read -r proto _ _ slug <<< "$page"
    file_anchor=$(anchor_filter "$proto")
    echo "s|%%FILEREF:${file_anchor}%%|../${slug}/|g" >> "$FILEREF_SED_SCRIPT"
done
# Also resolve scalar marker
echo "s|%%SCALAR%%|../scalar/|g" >> "$FILEREF_SED_SCRIPT"

gen_page() {
    local active_file="$1"
    local title="$2"
    local weight="$3"
    local slug="$4"
    local out_file="${slug}.md"
    local out_path="$PROJECT_DIR/content/docs/${OUT_DIR}/${out_file}"

    echo "Generating ${out_file} from ${active_file}..."

    # Pre-process template: inject active file name
    local tmp_template
    tmp_template=$(mktemp)
    sed "s|%%ACTIVE_FILE%%|${active_file}|g" "$TEMPLATE" > "$tmp_template"

    # Run protoc-gen-doc with ALL protos for full type resolution
    protoc \
        --doc_out="$PROJECT_DIR/content/docs/${OUT_DIR}" \
        --doc_opt="$tmp_template,${out_file}" \
        --proto_path="$PROTO_DIR" \
        "${ALL_PROTOS[@]}"

    rm -f "$tmp_template"

    # Post-process: replace %%WEIGHT%% and %%TITLE%%
    local escaped_title
    escaped_title=$(escape_sed "$title")
    sed -i.bak \
        -e "s/%%WEIGHT%%/${weight}/g" \
        -e "s/%%TITLE%%/${escaped_title}/g" \
        "$out_path" && rm -f "${out_path}.bak"

    # Post-process: resolve %%FILEREF:xxx%% and %%SCALAR%% markers
    sed -i.bak -f "$FILEREF_SED_SCRIPT" "$out_path" && rm -f "${out_path}.bak"

}

# Generate all pages
for page in "${PAGES[@]}"; do
    IFS='|' read -r proto title weight slug <<< "$page"
    gen_page "$proto" "$title" "$weight" "$slug"
done

rm -f "$FILEREF_SED_SCRIPT"

echo "Done. Generated ${#PAGES[@]} pages."
