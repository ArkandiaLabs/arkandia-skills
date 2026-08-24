# Hook 7 — generated-file guard. PreToolUse, matcher Edit|Write|MultiEdit.
H=generated-files-guard.sh

check $H deny 'packages.lock.json'       "$(payload_file Edit /repo/packages.lock.json)"
check $H deny 'a nested lock file'       "$(payload_file Edit /repo/src/Api/packages.lock.json)"

# `Migrations/` is not proof of EF Core. DbUp and FluentMigrator use the same directory name for
# migrations written BY HAND — blocking those stops normal work and hands the team advice for a
# tool they do not use. The ModelSnapshot file is what makes the directory EF Core's.
EF="$WORK/ef/src/Data/Migrations"; HAND="$WORK/hand/db/Migrations"
mkdir -p "$EF" "$HAND"
: > "$EF/20260101_Init.cs"; : > "$EF/AppDbContextModelSnapshot.cs"
: > "$HAND/0001_create_tables.cs"

check $H deny   'EF Core migration'       "$(payload_file Edit "$EF/20260101_Init.cs")"
check $H deny   'the snapshot itself'     "$(payload_file Edit "$EF/AppDbContextModelSnapshot.cs")"
check $H silent 'hand-written migration'  "$(payload_file Edit "$HAND/0001_create_tables.cs")"

# Segment-anchored, so a name that merely contains the word is untouched.
check $H silent 'MigrationsHelper.cs'    "$(payload_file Edit /repo/src/MigrationsHelper.cs)"
check $H silent 'docs/migrations.md'     "$(payload_file Edit /repo/docs/migrations-guide.md)"
check $H silent 'a normal .cs'           "$(payload_file Edit /repo/src/Program.cs)"
check $H silent 'Directory.Packages.props' "$(payload_file Edit /repo/Directory.Packages.props)"
check $H silent 'empty payload'          ''
