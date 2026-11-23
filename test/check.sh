#!/usr/bin/env bash
# Structure check for the gabeul skill: table paths exist, every rule file is listed,
# the SKILL.md table and the gallery table name the same 신분, no 시험 left in examples.
cd "$(dirname "$0")/../skills/gabeul" || exit 2
fail=0

fm=$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1' SKILL.md)
[ "$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')" = gabeul ] || { echo "FAIL SKILL.md frontmatter name is not bunsoo"; fail=1; }
printf '%s\n' "$fm" | grep -q '^description: *[^ ]' || { echo "FAIL SKILL.md has no description"; fail=1; }

# every references/ file named in the SKILL.md table exists
listed=$(grep -o 'references/[a-z]*\.md' SKILL.md | sort -u)
for f in $listed; do [ -f "$f" ] || { echo "FAIL SKILL.md names $f, which does not exist"; fail=1; }; done

# every rule file (all but gallery.md) is listed in the SKILL.md table
for f in references/*.md; do
  [ "$f" = references/gallery.md ] && continue
  grep -q "$f" SKILL.md || { echo "FAIL $f is not in the SKILL.md table"; fail=1; }
done

# the 신분 names in the two tables match
names_skill=$(awk -F'|' '/^\| [^|]*\| 사용자가 (갑|을)|^\| [^|]*\| 대등/{gsub(/ /,"",$2); print $2}' SKILL.md | sort)
names_gallery=$(grep -o '`/gabeul [^`]*`' references/gallery.md | sed 's/`\/gabeul //; s/`$//; s/ //g' | grep -Ev '^(목록|끄기)$' | sort -u)
names_skill=$(printf '%s\n' "$names_skill" | sed 's/ //g' | sort -u)
[ "$names_skill" = "$names_gallery" ] || { echo "FAIL SKILL.md and gallery.md name different 신분"; diff <(echo "$names_skill") <(echo "$names_gallery"); fail=1; }

# examples use the marketer scenario (광고 시안), not the old 테스트/시험 ones
if grep -rnE '시험|테스트 (2개|둘)' SKILL.md references | grep -q .; then echo "FAIL old example wording found (시험 or 테스트 2개):"; grep -rnE '시험|테스트 (2개|둘)' SKILL.md references | head -3; fail=1; fi

[ $fail = 0 ] && echo "gabeul: all passed"
exit $fail
