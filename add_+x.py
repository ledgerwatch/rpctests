#!/usr/bin/env python3

"""
Add +x to every .sh file
"""

# import argparse
import os
import subprocess


def go_recursive(search_dir: str):
    objects = os.listdir(search_dir)

    for obj in objects:
        if obj == ".git":
            continue

        obj_path = f"{search_dir}/{obj}"
        if os.path.isdir(obj_path):
            go_recursive(obj_path)

        if os.path.isfile(obj_path) and obj.endswith(".sh"):
            try:
                subprocess.run(["chmod", "+x", obj_path])
            except:
                print("There is an exception")

go_recursive(".")