#!/usr/bin/env python3
import os, yaml, sys, itertools, re, shutil

specs={}
repo = sys.argv[1] + "/" if len(sys.argv) > 1 else ""
for d in [ d for d in os.listdir(".") if not d.startswith(".") and os.path.isdir(d) and os.path.isfile(os.path.join(d,"spec.yaml"))]:
    with open(os.path.join(d,"spec.yaml")) as f:
        specs[d]=yaml.load(f)
print(yaml.dump(specs))

def replaceVars(vars):
    return lambda matchobj : str(vars[matchobj.group(1)])

generated_dir="generated"

shutil.rmtree(generated_dir)
os.makedirs(generated_dir, exist_ok=True)

for k in specs.keys():
    for ts in [dict(zip(specs[k]["tags"].keys(), values)) for values in itertools.product(*specs[k]["tags"].values())]:
        image = repo + specs[k]["image"] + ":" + "_".join([str(ts[ts_key]) for ts_key in sorted(ts.keys())])
        dst_dockerfile = os.path.join(generated_dir,"Dockerfile." + image.replace("/","_"))
        print(dst_dockerfile, " <- ", k , " + ", ts)
        with open(dst_dockerfile, "w+") as dest, open(os.path.join(k,"Dockerfile"), "r") as src:
            for line in src.readlines():
                if "ARG" in line:
                    continue
                else:
                    pattern ="\$\{\s*("+"|".join(list(ts.keys()))+")\s*\}"
                    line = re.sub(pattern, replaceVars(ts), line)
                    dest.write(line)

