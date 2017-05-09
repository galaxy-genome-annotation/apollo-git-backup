# Apollo Backup

This repository contains a complete backup of our [Apollo](https://cpt.tamu.edu/apollo/) instance in the exported .gff3, .fa
artefacts.

Data is in [./data/](./data/)

## Requirements

- python
- jq

## Setup

```
pip install -r requirements.txt
```

## Running

```
export APOLLO_USERNAME=jane.doe@fqdn.edu
export APOLLO_PASSWORD=password
bash run.sh
```

This will produce a JUnit compatible report.xml. The developers of this project
run it as a cron job in Jenkins and consume the XUnit report to ensure that it
is functioning correctly.
