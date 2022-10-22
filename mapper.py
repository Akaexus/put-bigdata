#!/usr/bin/env python3
import sys

# title                   person_id
# tconst  ordering        nconst  category        job     characters
for line in sys.stdin:
    [_, _, nconst, category, _, _] = line.split("\t")
    if category == 'actor' or category == 'actress' or category == 'self':
        print(f'{nconst}\t1\t0')
    elif category == 'director':
        print(f'{nconst}\t0\t1')