#!/usr/bin/python

# author: mike fullerton

import sys
import os

my_path = os.path.realpath(__file__)
my_dir = os.path.realpath(os.path.dirname(my_path))
my_parent_dir = os.path.dirname(my_dir)

def find_sounds_folder():