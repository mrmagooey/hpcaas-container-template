#!/usr/bin/env python

from __future__ import print_function

import json
import os

scripts_directory = os.path.dirname(os.path.realpath(__file__))
parent_directory = os.path.dirname(scripts_directory)

with open(os.path.join(parent_directory, 'config.json')) as metadata_file:
    metadata = json.load(metadata_file)["metadata"]
    print("%s/%s:%s" % (metadata["author"], metadata['container_name'],
                        metadata['version']))
