rm -f data/*
# Export data
python export.py https://cpt.tamu.edu/apollo_api $APOLLO_USERNAME $APOLLO_PASSWORD > report.xml
git add -f data
date=$(date)
git commit -m "Automated Commit [$date]"

# Lineage
jq '[.id,.commonName] | @tsv ' -r < data/*.json > id-map.tsv
bash lineage.sh
git add data/*.lin.txt;
date=$(date)
git commit -m "Automated Commit for Lineage Data [$date]"
