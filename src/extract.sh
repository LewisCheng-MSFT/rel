#!/bin/bash
# script extracting records from:
# "(d1.after(10)-d1.after(20)).in(30,50,5)"

# T0 = d1.after
gawk -f after -v v1=10.00 d1 > T0

# T1 = d1.after
gawk -f after -v v1=20.00 d1 > T1

# T2 = T0 minus T1
sort T0 T1 T1 | uniq -u > T2

# T3 = T2.in
gawk -f in -v v3=5.00 -v v2=50.00 -v v1=30.00 T2 > T3

# print result!
sort -n -k2 T3

