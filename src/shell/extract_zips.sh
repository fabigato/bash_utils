#!/bin/bash
# Deliberately no `set -e`: a single unreadable zip must not abort the whole run.
set -uo pipefail

# ── Argument parsing ─────────────────────────────────────────────────
# Flags:  -P password
# Pos:    $1 = SOURCE (mandatory), $2 = DEST (mandatory)
#           PASS = PASSWORD env var > ~/repos/ww.txt

PW_ARG=""
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -[pP])
            PW_ARG="$2"
            shift 2
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

SOURCE_DIR="${POSITIONAL[0]:-}"
DEST_BASE="${POSITIONAL[1]:-}"

# ── Mandatory arg validation ─────────────────────────────────────────
if [[ -z "$SOURCE_DIR" ]]; then
    echo "Usage: bash extract_zips.sh SOURCE DEST [-P password]" >&2
    exit 1
fi
if [[ -z "$DEST_BASE" ]]; then
    echo "Usage: bash extract_zips.sh SOURCE DEST [-P password]" >&2
    exit 1
fi

# ── Password resolution ──────────────────────────────────────────────
# Priority: -P flag > PASSWORD env var > ~/repos/ww.txt
if [[ -n "$PW_ARG" ]]; then
    PASSWORD="$PW_ARG"
elif [[ -n "${PASSWORD:-}" ]]; then
    : # already set from env
else
    PASSWORD=$(tr -d '\n' < "$HOME/repos/ww.txt")
fi

# macOS rejects filenames that aren't valid UTF-8 (EILSEQ, "Illegal byte
# sequence") on both APFS and ZFS, so archives whose entry names are in a DOS
# codepage cannot be unpacked by unzip at all -- it fails per entry and then
# exits 50 ("disk full") or 2, which is thoroughly misleading. libarchive can
# transcode the names on the way out, which is the fallback below.
#
# Two different charsets are in play and they are NOT interchangeable:
#
#   ZIP_CHARSET  - the encoding of the raw bytes stored in the archive. The ZIP
#                  spec says non-UTF-8 names are IBM CP437, and that is what
#                  bsdtar needs, since it reads those bytes verbatim.
#   LIST_CHARSET - `unzip -Z1` does NOT report raw bytes; it has already
#                  translated them to the local 8-bit charset. Undoing that is
#                  what turns a listed name into the UTF-8 form on disk, so it
#                  is the charset used for the existence checks.
#
# Concretely, for U+00F1: the archive holds 0xA4 (CP437), `unzip -Z1` prints
# 0xF1 (Latin-1), and the file lands as UTF-8. Reading the raw 0xA4 as Latin-1
# instead yields the wrong character entirely (U+00A4).
ZIP_CHARSET="${ZIP_CHARSET:-CP437}"
LIST_CHARSET="${LIST_CHARSET:-ISO-8859-1}"

# NOTE: do NOT set LC_ALL=C for the whole script. `unzip -Z1` translates DOS
# codepage names into the locale's charset, and under the C locale it cannot
# represent them, so it substitutes a literal '?' -- destroying the bytes before
# anything can recover them. The locale is left alone so unzip yields Latin-1,
# and LC_ALL=C is applied per-command to the grep/sed calls that would otherwise
# abort with "illegal byte sequence" on those same names.

SOURCE_ABS=$(cd "$SOURCE_DIR" && pwd) || exit 1
DEST_BASE="${DEST_BASE%/}"
mkdir -p "$DEST_BASE" || exit 1

echo "Source: $SOURCE_ABS"
echo "Dest:   $DEST_BASE"
echo "Pass:   ${#PASSWORD} chars"
echo "---"

N_OK=0
N_SKIP=0
N_FAIL=0
FAILURES=""

# ── Helpers ──────────────────────────────────────────────────────────

# Extract into a directory, falling back to bsdtar for archives whose
# encryption/compression Info-ZIP 6.0 cannot handle (rc 81 -- e.g. WinZip
# AES, reported as "need PK compat. v5.1"). bsdtar/libarchive reads those.
#
# Returns 0 only on genuine success. The two tools disagree about exit 1:
# unzip means "warnings, output is fine", bsdtar means "errors occurred"
# (it exits 1 on a bad passphrase, after having already written a full-size
# file of undecrypted garbage). So each is judged on its own scale, and the
# raw code is left in RUN_RC for error messages.
# bsdtar/libarchive extraction. A non-empty $3 makes it transcode entry names
# from that charset into UTF-8. Kept separate so both fallbacks below share it.
# stdin is closed: see the note on the main loop about children eating the
# zip list.
run_bsdtar() {
    local zip_path="$1"
    local out_dir="$2"
    local charset="$3"

    if [[ -n "$charset" ]]; then
        ( cd "$out_dir" && bsdtar --passphrase "$PASSWORD" \
              --options "hdrcharset=$charset" -x -f "$zip_path" </dev/null )
    else
        ( cd "$out_dir" && bsdtar --passphrase "$PASSWORD" \
              -x -f "$zip_path" </dev/null )
    fi
    RUN_RC=$?
    [[ $RUN_RC -eq 0 ]] && return 0
    return 1
}

run_unzip() {
    local zip_path="$1"
    local out_dir="$2"
    local err
    err=$(mktemp "${TMPDIR:-/tmp}/xtract.err.XXXXXX") || err=""

    if [[ -n "$err" ]]; then
        unzip -o -q -P "$PASSWORD" -d "$out_dir" "$zip_path" </dev/null 2>"$err"
    else
        unzip -o -q -P "$PASSWORD" -d "$out_dir" "$zip_path" </dev/null
    fi
    RUN_RC=$?

    # WinZip AES etc: Info-ZIP 6.0 reports rc 81 ("need PK compat. v5.1").
    if [[ $RUN_RC -eq 81 ]]; then
        echo "    note: unsupported method for unzip (AES?), retrying with bsdtar"
        [[ -n "$err" ]] && rm -f "$err"
        rm -rf "$out_dir"/* 2>/dev/null
        run_bsdtar "$zip_path" "$out_dir" ""
        return $?
    fi

    # Entry names that aren't valid UTF-8 cannot be created on a utf8only
    # dataset regardless of unzip's exit code -- it reports EILSEQ per entry and
    # then exits 50 ("disk full") or 2, which is misleading. Retry the whole
    # archive through libarchive with the names transcoded.
    if [[ -n "$err" ]] && LC_ALL=C grep -q 'Illegal byte sequence' "$err"; then
        echo "    note: non-UTF-8 entry names, retrying with bsdtar hdrcharset=$ZIP_CHARSET"
        rm -f "$err"
        rm -rf "$out_dir"/* 2>/dev/null
        run_bsdtar "$zip_path" "$out_dir" "$ZIP_CHARSET"
        return $?
    fi

    if [[ -n "$err" ]]; then
        cat "$err" >&2
        rm -f "$err"
    fi

    [[ $RUN_RC -le 1 ]] && return 0
    return 1
}

# Does $2 exist under $1, either as named in the archive or as the UTF-8
# transcoding of that name? The raw check is the fast path; the iconv only runs
# when it misses, so archives with clean ASCII names pay nothing.
entry_exists() {
    local base="$1"
    local rel="$2"
    local alt

    [[ -e "$base/$rel" ]] && return 0
    # LIST_CHARSET, not ZIP_CHARSET: $rel came from `unzip -Z1`, which already
    # translated the archive's raw bytes into the local 8-bit charset.
    alt=$(printf '%s' "$rel" | iconv -f "$LIST_CHARSET" -t UTF-8 2>/dev/null)
    [[ -n "$alt" && "$alt" != "$rel" && -e "$base/$alt" ]] && return 0
    return 1
}

# Move everything inside $1 into $2, merging into pre-existing directories.
move_contents() {
    local src="$1"
    local dst="$2"
    local f rc=0

    shopt -s dotglob nullglob
    for f in "$src"/*; do
        if ! mv -f "$f" "$dst"/ 2>/dev/null; then
            # Target already has an entry of that name that mv won't clobber
            # (typically a non-empty directory) -- merge it instead.
            if ditto "$f" "$dst/$(basename "$f")"; then
                rm -rf "$f"
            else
                echo "    move failed: $f" >&2
                rc=1
            fi
        fi
    done
    shopt -u dotglob nullglob

    return $rc
}

# ── Per-zip extraction ───────────────────────────────────────────────
# Never returns non-zero; records the outcome in RESULT / RESULT_MSG.
extract_zip() {
    local zip_path="$1"
    local dest_dir="$2"
    local zip_basename="$3"

    RESULT="fail"
    RESULT_MSG=""

    local entries
    entries=$(unzip -Z1 "$zip_path" </dev/null 2>/dev/null | LC_ALL=C grep -v '^$')

    # `unzip -Z1` cannot represent entry names that are already valid UTF-8 --
    # whether flagged as such in the archive or just incidentally multi-byte --
    # and substitutes a literal '?' for the bytes it can't map. The name then
    # never matches what actually landed on disk, so the verification below
    # discards a perfectly good extraction. libarchive reports those names
    # faithfully. This is only a fallback because for DOS-codepage names it is
    # the unzip listing plus LIST_CHARSET that round-trips, and `bsdtar -tf`
    # with an explicit hdrcharset returns nothing at all for these archives.
    if [[ "$entries" == *'?'* ]]; then
        local entries_alt
        entries_alt=$(bsdtar -tf "$zip_path" </dev/null 2>/dev/null | LC_ALL=C grep -v '^$')
        if [[ -n "$entries_alt" ]]; then
            echo "    note: unzip mangled non-ASCII entry names, listing via bsdtar"
            entries="$entries_alt"
        fi
    fi

    if [[ -z "$entries" ]]; then
        RESULT_MSG="cannot list archive contents"
        return 0
    fi

    # A single top-level component shared by every entry is a wrapper
    # directory we strip, so we don't end up with dest/name/name/...
    local roots n_roots root_name=""
    roots=$(printf '%s\n' "$entries" | LC_ALL=C sed 's:/.*::' | LC_ALL=C sort -u)
    n_roots=$(printf '%s\n' "$roots" | LC_ALL=C grep -c .)
    if [[ "$n_roots" -eq 1 ]] && ! printf '%s\n' "$entries" | LC_ALL=C grep -qv '/'; then
        root_name="$roots"
    fi

    # Archive paths rewritten relative to wherever we're going to put them,
    # and a count of real files (directory entries end in '/').
    local rel_paths="" n_files=0 entry rel
    while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        rel="$entry"
        if [[ -n "$root_name" ]]; then
            [[ "$rel" == "$root_name" || "$rel" == "$root_name/" ]] && continue
            rel="${rel#$root_name/}"
        fi
        [[ "$entry" != */ ]] && n_files=$((n_files + 1))
        rel="${rel%/}"
        [[ -z "$rel" ]] && continue
        rel_paths="$rel_paths$rel"$'\n'
    done <<< "$entries"

    # One file goes next to its siblings; several get their own folder.
    local target
    if [[ "$n_files" -le 1 ]]; then
        target="$dest_dir"
    else
        target="$dest_dir/$zip_basename"
    fi

    # ── Idempotency check ────────────────────────────────────────────
    local missing=0
    while IFS= read -r rel; do
        [[ -z "$rel" ]] && continue
        entry_exists "$target" "$rel" || missing=$((missing + 1))
    done <<< "$rel_paths"

    if [[ "$missing" -eq 0 ]]; then
        if [[ "$n_files" -le 1 ]]; then
            echo "SKIP (exists): $zip_basename -> $target/"
        else
            echo "SKIP (exists): $zip_basename -> $target/"
        fi
        RESULT="skip"
        return 0
    fi

    if [[ "$n_files" -le 1 ]]; then
        echo "EXTRACT (single): $zip_basename -> $target/"
    else
        echo "EXTRACT (multi): $zip_basename -> $target/"
    fi

    # A file sitting where we need a directory
    if [[ -e "$target" && ! -d "$target" ]]; then
        rm -f "$target"
    fi
    mkdir -p "$target" || { RESULT_MSG="cannot create $target"; return 0; }

    # Always unpack into a staging dir *inside* the target (same filesystem,
    # so committing below is a rename, not a copy) and only move the result
    # into place once it verifies. A failed decrypt therefore leaves the
    # destination untouched, so the next run retries it instead of finding
    # half-written garbage and skipping it forever.
    local tmpdir
    tmpdir=$(mktemp -d "$target/.xtract.XXXXXX") || {
        RESULT_MSG="cannot create temp dir in $target"; return 0; }

    RUN_RC=0
    if ! run_unzip "$zip_path" "$tmpdir"; then
        rm -rf "$tmpdir"
        RESULT_MSG="extraction failed (rc=$RUN_RC); destination left untouched"
        return 0
    fi

    # Where the extracted payload actually is, wrapper directory stripped.
    # The wrapper directory may have been transcoded on the way out, so look for
    # the UTF-8 form too or we'd fail to strip it and nest dest/name/name.
    local stage="$tmpdir" root_alt
    if [[ -n "$root_name" ]]; then
        if [[ -d "$tmpdir/$root_name" ]]; then
            stage="$tmpdir/$root_name"
        else
            root_alt=$(printf '%s' "$root_name" | iconv -f "$LIST_CHARSET" -t UTF-8 2>/dev/null)
            [[ -n "$root_alt" && -d "$tmpdir/$root_alt" ]] && stage="$tmpdir/$root_alt"
        fi
    fi

    missing=0
    while IFS= read -r rel; do
        [[ -z "$rel" ]] && continue
        entry_exists "$stage" "$rel" || missing=$((missing + 1))
    done <<< "$rel_paths"

    if [[ "$missing" -gt 0 ]]; then
        rm -rf "$tmpdir"
        RESULT_MSG="$missing of $n_files entr(ies) missing after extraction (rc=$RUN_RC); destination left untouched"
        return 0
    fi

    if move_contents "$stage" "$target"; then
        RESULT="ok"
    else
        RESULT_MSG="extracted but could not move all files into $target"
    fi
    rm -rf "$tmpdir"
    return 0
}

# ── Walk the source tree, mirroring its folder structure ─────────────
# Process substitution (not a pipe) so the loop runs in this shell and the
# counters below survive it.
#
# The list is read on fd 9, NOT stdin. On stdin, any child that reads from it
# swallows a buffer's worth of the pending zip list and those archives are
# never processed -- silently, with no log line, so the run still reports
# success. That cost 434 of 821 zips on the 2026-09-06 run (unzip re-prompting
# after per-entry write errors). Children also get </dev/null individually.
while IFS= read -r -u 9 -d '' zip_path; do
    zip_basename=$(basename "$zip_path" .zip)

    rel_path="${zip_path#$SOURCE_ABS/}"
    sub_dir=$(dirname "$rel_path")
    if [[ "$sub_dir" == "." ]]; then
        dest_dir="$DEST_BASE"
    else
        dest_dir="$DEST_BASE/$sub_dir"
    fi

    if ! mkdir -p "$dest_dir"; then
        echo "FAILED: $zip_basename (cannot create $dest_dir)" >&2
        N_FAIL=$((N_FAIL + 1))
        FAILURES="$FAILURES  $rel_path: cannot create dest dir"$'\n'
        continue
    fi

    extract_zip "$zip_path" "$dest_dir" "$zip_basename"

    case "$RESULT" in
        ok)   N_OK=$((N_OK + 1)) ;;
        skip) N_SKIP=$((N_SKIP + 1)) ;;
        *)
            echo "    FAILED: $RESULT_MSG" >&2
            N_FAIL=$((N_FAIL + 1))
            FAILURES="$FAILURES  $rel_path: $RESULT_MSG"$'\n'
            ;;
    esac
done 9< <(find "$SOURCE_ABS" -name '*.zip' -print0 | sort -z)

echo ""
echo "Done!  extracted=$N_OK  skipped=$N_SKIP  failed=$N_FAIL"
if [[ "$N_FAIL" -gt 0 ]]; then
    echo ""
    echo "Failures:"
    printf '%s' "$FAILURES"
    exit 1
fi
