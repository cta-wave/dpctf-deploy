#!/usr/bin/python

import sys
import os
import shutil, errno
from pathlib import Path
import hashlib
import json
import urllib.request
import re
import zipfile
import time
from urllib.parse import urlparse


if len(sys.argv) < 3:
    print("Please provide a json file and destination directory!")
    sys.exit(1)

JSON_PATH = sys.argv[1]
DEST_DIR = sys.argv[2]


def main():
    json_file = load_json(JSON_PATH)

    for vector_name in json_file:
        vector = json_file[vector_name]

        relative_path = vector["mpdPath"]
        relative_path = os.path.dirname(relative_path)
        absolute_path = os.path.join(DEST_DIR, relative_path)
        if os.path.exists(absolute_path):
            print("Path '" + absolute_path  + "' exists. Skipping ...");
            continue;

        if "zipPath" not in vector:
            print("Vector '" + vector_name + "' does not specify zip path, skipping ...")
            continue

        url = vector["zipPath"]

        if url.startswith("/"):
            parsed_uri = urlparse(JSON_PATH)
            url = '{uri.scheme}://{uri.netloc}{path}'.format(uri=parsed_uri, path=url)
        elif not url.startswith("http"):
            parsed_uri = urlparse(JSON_PATH)
            url = '{uri.scheme}://{uri.netloc}{path}'.format(uri=parsed_uri, path=os.path.join(os.path.dirname(parsed_uri.path), url))

        blob = load_zip(url)
        if blob is None:
            continue

        tmp_file_name = "{}.zip".format(str(time.time()))
        with open(tmp_file_name, "wb") as file:
            file.write(blob)

        with zipfile.ZipFile(tmp_file_name, "r") as zip:
            #path = os.path.join(DEST_DIR, vector_name)
            zip.extractall(path=DEST_DIR)
        

        files = os.listdir(".")
        for file in files:
            if re.match(r"\d+\.\d+\.zip", file) is None:
                continue
            os.remove(file)



def load_json(json_path):
    content = ""
    if json_path.startswith("http"):
        print("Fetching JSON {}".format(json_path))
        try:
            content = urllib.request.urlopen(json_path).read()
        except urllib.error.HTTPError:
            print("Could not load http url:", json_path)
            return None
    else:
        file_path = Path(json_path).absolute()
        print("Reading JSON {}".format(file_path))
        if not os.path.isfile(file_path):
            print("Could not find file:", file_path)
            return None
        with open(file_path, "r") as file:
            content = file.read()
    
    if type(content) is not str:
        content = content.decode("utf-8")
    return json.loads(content)

def load_zip(path):
    content = None
    print("Fetching zip {}".format(path))
    try:
        content = urllib.request.urlopen(path).read()
    except urllib.error.HTTPError:
        print("Could not load http url:", path)
    return content


def load_file(path):
    with open(path, "r") as file:
        return file.read()

def write_file(path, content):
    parent = Path(path).parent
    if not parent.exists():
        os.makedirs(parent)

    with open(path, "w+") as file:
        file.write(content)

def copy(src, dest):
    if Path(dest).exists():
        return
    try:
        shutil.copytree(src, dest)
    except OSError as error:
        if error.errno == errno.ENOTDIR:
            shutil.copy(src, dest)
        else: raise

main()
