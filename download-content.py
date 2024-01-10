#!/usr/bin/python3

import sys
import os
import shutil, errno
from pathlib import Path
#import hashlib
import json
import urllib.request
import re
import zipfile
import time
<<<<<<< HEAD
import threading
=======
>>>>>>> tmp
from datetime import datetime
from urllib.parse import urlparse


if len(sys.argv) < 3:
    print("Please provide a json file and destination directory!")
    sys.exit(1)

JSON_PATH = sys.argv[1]
DEST_DIR = sys.argv[2]


def main():
    json_file = load_json(JSON_PATH)
    for profile_name in json_file:
        vectors = json_file[profile_name]
        for vector_name in vectors:
            vector = vectors[vector_name]
            if "zipPath" not in vector or "mpdPath" not in vector:
                print("Vector '" + vector_name + "' does not specify zip or mpd path, skipping ...")
                continue
            mpd_path = vector["mpdPath"]
            mpd_path = mpd_path.split("/")[-4:]
            mpd_path = "/".join(mpd_path)
            mpd_path = os.path.dirname(mpd_path)
            download_path = os.path.join(DEST_DIR, mpd_path)
            if os.path.exists(download_path):
                print("Path '" + download_path  + "' exists. Skipping ...")
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
                print("Extracting ..", end="")
                stop_event = threading.Event()
                def print_dot():
                    while not stop_event.is_set():
                        print(".", end="")
                        time.sleep(5)
                worker = threading.Thread(target=print_dot)
                worker.start()
                zip.extractall(path=DEST_DIR)
                print()
                stop_event.set()
            

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
    retries = 3
    current_try = 0
    last_time = datetime.now()
    while current_try < retries:
        try:
            #content = urllib.request.urlopen(path).read()
            response = urllib.request.urlopen(path)
            total_length = response.length
            content = bytearray(total_length)
            view = memoryview(content)
            pos = 0
            CHUNK_SIZE = 1024 * 1024
            INTERVAL_SECONDS = 5
            while True:
                chunk = response.read(CHUNK_SIZE)
                if len(chunk) == 0:
                    break
                view[pos:pos+len(chunk)] = chunk
                pos += len(chunk)
                time_diff = datetime.now() - last_time
                if time_diff.total_seconds() >= INTERVAL_SECONDS:
                    last_time = datetime.now()
                    percent = round(pos/total_length*100, 2)
                    print(str(percent) + "% complete")
            return content
        except urllib.error.HTTPError:
            print("HTTPError. Retrying ...")
            current_try += 1
        except urllib.error.URLError:
            print("URLError. Retrying ...")
            current_try += 1


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
