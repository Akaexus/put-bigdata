#!/usr/bin/env python3
import sys

person = None
acted = 0
directed = 0

for line in sys.stdin:
    [current_person, current_acted, current_directed] = line.split('\t')
    current_acted = int(current_acted)
    current_directed = int(current_directed)
    if current_person != person:
        if person is not None:
            print(f'{person}\t{acted}\t{directed}')
        person = current_person
        acted = current_acted
        directed = current_directed
    else:
        acted += current_acted
        directed += current_directed
if person is not None:
    print(f'{person}\t{acted}\t{directed}')