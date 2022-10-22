#!/usr/bin/env bash
cat input/datasource1/1kk_title.principals.tsv | python3 mapper.py | sort -k1,1 | python3 combiner.py