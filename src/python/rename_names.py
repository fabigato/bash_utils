#!/usr/bin/env python3
"""Recursively replace literal, case-sensitive text in descendant names.

Usage: python3 rename_names.py DIRECTORY OLD NEW
File contents and DIRECTORY's own name are unchanged. Symlinks are renamed,
but their targets are never traversed. Uses only the Python standard library.
"""

import argparse
import os
from pathlib import Path
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("old", help="Literal text to replace (case-sensitive)")
    parser.add_argument("new", help="Replacement text")
    parser.add_argument("--dry-run", action="store_true", help="Preview without renaming")
    args = parser.parse_args()

    def walk_error(error):
        raise error

    try:
        if not args.old:
            raise ValueError("Search text must not be empty")
        if not args.directory.is_dir():
            raise ValueError(f"Not a directory: {args.directory}")
        changes = []
        destinations = set()
        for parent, folders, files in os.walk(
            args.directory, topdown=False, followlinks=False, onerror=walk_error
        ):
            for name in sorted(folders + files):
                replacement = name.replace(args.old, args.new)
                if replacement != name:
                    source = Path(parent) / name
                    target = source.with_name(replacement)
                    if os.path.lexists(target):
                        raise ValueError(f"Destination already exists: {target}")
                    key = str(target)
                    if sys.platform in ("darwin", "win32"):
                        key = key.casefold()
                    if key in destinations:
                        raise ValueError(f"Multiple names would become: {target}")
                    destinations.add(key)
                    changes.append((source, target))
        for source, target in changes:
            if os.path.lexists(target):
                raise ValueError(f"Destination already exists: {target}")
            if not args.dry_run:
                source.rename(target)
            print(f"{str(source)!r} -> {str(target)!r}")
        print(f"{'Would rename' if args.dry_run else 'Renamed'} {len(changes)} entries.")
    except (OSError, ValueError) as error:
        parser.exit(1, f"Error: {error}\n")


if __name__ == "__main__":
    main()
