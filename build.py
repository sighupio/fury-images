#!/usr/bin/env python3
import os
import yaml
import sys
import itertools

specs={}
for d in [ d for d in os.listdir(".") if not d.startswith(".") and os.path.isdir(d) and os.path.isfile(os.path.join(d,"spec.yaml"))]:
    with open(os.path.join(d,"spec.yaml")) as f:
        specs[d]=yaml.load(f)
print(specs)
print([dict(zip(specs["furyctl"]["tags"].keys(), values)) for values in itertools.product(*specs["furyctl"]["tags"].values())])

for k in specs.keys():
    for ts in [dict(zip(specs[k]["tags"].keys(), values)) for values in itertools.product(*specs[k]["tags"].values())]:
        image = specs[k]["image"] + ":" + "_".join([str(ts[ts_key]) for ts_key in sorted(ts.keys())])
        print("building: " + image)
        build = "docker build " + " ".join(["--build-arg " + k + "=" + str(v) for (k,v) in ts.items()]) + " -t " + image + " " + k
        print(build)
        push = "docker push " + image
        if ( os.system(build) != 0 or os.system(push) != 0 ):
            sys.exit(1)

