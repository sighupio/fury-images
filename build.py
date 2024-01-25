#!/usr/bin/env python3
import os
import yaml
import sys
import itertools

specs = {}
errors = []
repo = sys.argv[1] + "/" if len(sys.argv) > 1 else ""
modified_files = set([os.path.dirname(file) for file in sys.argv[2:] ])
debug(modified_files)

# We need to build the images for all the modified files
for d in [d for d in os.listdir(".") if not d.startswith(".") and os.path.isdir(d) and d in modified_files and os.path.isfile(os.path.join(d, "spec.yaml"))]:
    with open(os.path.join(d,"spec.yaml")) as f:
        specs[d]=yaml.load(f, Loader=yaml.SafeLoader)
debug(yaml.dump(specs))

for k in specs.keys():
    is_multiarch = "platforms" in specs[k].keys()

    if is_multiarch:
        archs = get_archs(specs[k])
        lazy_create_builder("sighup")

    # For each spec's key, we do the cartesian product of the tags, then we generate a build for each combination of tags and architectures,
    # The result of the cartesian product is a dictionary of tags:values
    for ts in [dict(zip(specs[k]["tags"].keys(), values)) for values in itertools.product(*specs[k]["tags"].values())]:
        # An image result example would be: quay.io/sighup/node:20.7.0_18.7.0
        image = repo + specs[k]["image"] + ":" + "_".join([str(ts[ts_key]) for ts_key in sorted(ts.keys())])
        debug("building: " + image)

        # Finally, we build the image
        if is_multiarch:
            docker_buildx(ts, image, archs, errors)
        else:
            docker_build(ts, image, errors)

if len(errors) > 0:
    print("Errors found: {}".format(errors))
    sys.exit(1)

def docker_build(ts, image, errors):
    build = "docker build " + " ".join(["--build-arg " + k + "=" + str(v)
                                         for (k,v) in ts.items()]) + " -t " + image + " " + k
    debug(build)

    statusCode = os.system(build)
    if (statusCode != 0):
        errors.append("Error building image {}, status code: {}".format(image, statusCode))

    push = "docker push " + image
    statusCode = os.system(push)
    if (statusCode != 0):
        errors.append("Error pushing image {}, status code: {}".format(image, statusCode))

def docker_buildx(ts, image, archs, errors):
    buildx = "docker buildx build --builder sighup --push --platform {} ".format(archs)

    # A build result example would be: docker buildx build --builder sighup --push --platform linux/amd64,linux/arm64 --build-arg NODE_VERSION=18.7.0 --build-arg KUBECTL_VERSION=20.7.0 -t quay.io/sighup/node:20.7.0_18.7.0 node
    build = buildx + " ".join(["--build-arg " + k + "=" + str(v)
                                for (k, v) in ts.items()]) + " -t " + image + " " + k
    debug(build)

    statusCode = os.system(build)
    if (statusCode != 0):
        errors.append("Error building image {}, status code: {}".format(image, statusCode))

def lazy_create_builder(builder_name):
    """Create a new docker buildx builder.
    If the builder already exists, catch the exception and exit.
    else create the builder.
    """
    if os.system("docker buildx use 2> /dev/null" + builder_name) != 0:
        try:
            os.system("docker buildx create --name " + builder_name)
        except:
            print("could not create builder " + builder_name)
            sys.exit(1)


def get_archs(list):
    """Get the list of architectures to build for.
    """
    archs = "linux/amd64"
    # We get all specified architectures
    if "platforms" in list.keys():
        archs = ",".join([str(platform_key)
                          for platform_key in specs[k]["platforms"]])

    return archs

def debug(arg):
    if os.environ.get("DEBUG") == "true":
        print(arg)
        sys.stdout.flush()
