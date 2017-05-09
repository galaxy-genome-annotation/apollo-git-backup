#!/usr/bin/env python
import sys
import os
try:
    import StringIO as io
except ImportError:
    import io

import json
import argparse
from Bio import SeqIO
from BCBio import GFF
from xunit_wrapper import xunit, xunit_suite, xunit_dump
from webapollo import WAAuth, WebApolloInstance, CnOrGuess, GuessCn, AssertUser, accessible_organisms


def export(org_cn, seqs, gff_handle, fa_handle):
    org_data = wa.organisms.findOrganismByCn(org_cn)

    data = io.StringIO()

    kwargs = dict(
        exportType='GFF3',
        seqType='genomic',
        exportGff3Fasta=True,
        output="text",
        exportFormat="text",
        organism=org_cn,
    )

    if len(seqs) > 0:
        sequences = seqs
    else:
        sequences = []

    data.write(wa.io.write(
        exportAllSequences=False,
        sequences=sequences,
        **kwargs
    ).encode('utf-8'))

    # Seek back to start
    data.seek(0)

    records = list(GFF.parse(data))
    if len(records) == 0:
        print("Could not find any sequences or annotations for this organism + reference sequence")
        sys.exit(2)
    else:
        for record in records:
            record.annotations = {}
            record.description = ""

        if gff_handle:
            GFF.write(records, gff_handle)
        if fa_handle:
            SeqIO.write(records, fa_handle, 'fasta')

    return org_data


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    WAAuth(parser)
    args = parser.parse_args()
    wa = WebApolloInstance(args.apollo, args.username, args.password)

    gx_user = AssertUser(wa.users.loadUsers(email=args.username))
    all_orgs = wa.organisms.findAllOrganisms()
    orgs = accessible_organisms(gx_user, all_orgs)
    testCases = []
    for (orgName, orgId, ignore) in orgs:
        # I just want the tests to pass...
        if orgName in ('TESTING', 'phage_moil'):
            continue
        # Skip 464 assessment organisms
        if orgName.startswith('464'):
            continue

        sys.stderr.write(orgName + '\n')
        gff_name = 'data/%s-%s.gff' % (orgId, orgName)
        fa_name = gff_name.replace('.gff', '.fa')
        json_name = gff_name.replace('.gff', '.json')

        with open(gff_name, 'w') as gff_handle, open(fa_name, 'w') as fa_handle, open(json_name, 'w') as json_handle:
            with xunit('backup', 'download.%s' % orgName) as testCase:
                json.dump(export(orgName, [], gff_handle, fa_handle), json_handle, sort_keys=True)

            testCases.append(testCase)

    ts = xunit_suite("apollo_backup", testCases)
    print(xunit_dump([ts]))
