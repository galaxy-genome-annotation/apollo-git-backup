#!/bin/bash
# Remove old lineage files
rm -f lineage/*.txt;

for commit in $(git rev-list --reverse 72c328a3604455b5c03a9a69cab73f8bd1ceea8..master); do
	echo $commit;
	git checkout $commit;

	find data/ -name '*.json' -print0 | while read -d $'\0' file; do
		newname=$(echo "$file" | sed  's|data/[0-9]\+-||;s|.json|.txt|');
		cat "$file" | jq '.directory' >> "${newname}"
	done
done;

# Reduce file size by making entries unique.
git checkout master
find . -maxdepth 1 -type f -name '*.txt' -print0 | while read -d $'\0' file; do
	cat "$file" | uniq > "lineage/${file}";
	rm -f "$file"
done
