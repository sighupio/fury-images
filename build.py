#!/usr/bin/env python3
import os
import yaml
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
        os.system("docker build " + " ".join(["--build-arg " + k + "=" + str(v) for (k,v) in ts.items()]) + " -t " + image + " " + k )
        os.system("docker push " + image)


