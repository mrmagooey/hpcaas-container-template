#!/usr/bin/env python

from __future__ import print_function

import json
import os
import sys

scripts_directory = os.path.dirname(os.path.realpath(__file__))
parent_directory = os.path.dirname(scripts_directory)

with open(os.path.join(parent_directory, 'config.json')) as config_file:
    config = json.load(config_file)
    value = config[sys.argv[1]]
    json_val = json.dumps(value)
    escaped = json_val.replace("\"", "\\\"")
    print(escaped)
