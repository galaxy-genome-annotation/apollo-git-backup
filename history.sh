#!/bin/bash

function process_file(){
	file=$1
	commit=$2
	identifier=$3
	commit_date=$(git show -s --format=%cd --date=format:'%Y-%m-%d %R' $commit)
	relative_date=$(git show -s --format=%cr $commit)

	perl ../jbrowse/bin/flatfile-to-json.pl \
		--gff "$file" \
		--config "{ \"category\": \"Historical Data / $relative_date\"  }" \
		--key " $commit_date" \
		--out history/$identifier/ \
		--trackLabel "auto-$identifier-$commit";
}

# For all commits since root commit
for commit in $(git rev-list --reverse 72c328a3604455b5c03a9a69cab73f8bd1ceea8..master); do
	echo $commit;
	git checkout $commit > /dev/null;

	find data/ -name '*.gff' -print0 | while read -d $'\0' file; do
		org_name=$(basename "$file" .gff | sed 's/^[0-9]\+-//')
		# Check if there were changes.
		git diff $commit~1..$commit "$file" > /dev/null
		# 0 exit code is important.
		git_diff_exit=$?
		if [ "$git_diff_exit" -ne 0 ]; then
			# This file is NEW.
			process_file "$file" "$commit" "$org_name"
		else
			lines_changed=$(git diff $commit~1..$commit "$file" | wc -l)
			#echo "Lines changed: $lines_changed"
			if [ "$lines_changed" -ne 0 ]; then
				process_file "$file" "$commit"  "$org_name"
			fi
		fi
	done
done;
# Reduce file size by making entries unique.
git checkout master
