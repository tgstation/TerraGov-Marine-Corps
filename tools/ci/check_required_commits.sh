echo "$REQUIRED_COMMITS" |
	while IFS=$'\t' read -r commit title; do
		if [[ $(git cat-file -t "$commit") != "commit" ]]; then
			echo "Missing commit $commit: $title"
			exit 1
		fi
	done
