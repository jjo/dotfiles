# Glob behavior: don't abort on partially-empty brace globs.
# Example: ls *.{libsonnet,jsonnet} succeeds when only .jsonnet matches.
# csh_null_glob: empty match silently dropped if ANY pattern matches;
# error only when ALL patterns fail.
setopt csh_null_glob
