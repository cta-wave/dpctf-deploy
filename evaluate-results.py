import os
import json
import csv
import sys
import re
import argparse

def read_json_files(file_names):
    data = []
    for file_name in file_names:
        with open(file_name, 'r') as f:
            json_data = json.load(f)
            json_data["filename"] = file_name
            data.append(json_data)
    return data

def collect_keys(data, keys):
    collected_data = []
    for item in data:
        collected_item = {key: item.get(key, None) for key in keys}
        collected_data.append(collected_item)
    return collected_data

def collect_data(data, regex_list):
    collected_data = {}
    for file_data in data:
        file_name = file_data["filename"]
        file_name = os.path.splitext(file_name)[0]
        results = file_data.get("results")
        for test in results:
            name = test.get("test")
            status = test.get("status")
            if name not in collected_data:
                collected_data[name] = {}
            test_data = collected_data[name]
            if "status" not in test_data:
                test_data["status"] = {}
            test_data["status"][file_name] = status
            if "subtests" not in test_data:
                test_data["subtests"] = {}
                
            if status == "TIMEOUT": continue            
            subtests = test.get("subtests")
            for subtest in subtests:
                name = subtest.get("name")
                status = subtest.get("status")
                message = subtest.get("message")
                if message is None:
                    message = ""
                if name not in test_data["subtests"]:
                    test_data["subtests"][name] = {}
                subtest_data = test_data["subtests"][name]
                
                value = status + ": " + message
                
                if regex_list is not None:
                    value = parse_values(regex_list, message)
                
                subtest_data[file_name] = value

    return collected_data

def parse_values(regex_list, message):
    for regex in regex_list:
        match = re.search(regex, message)
        if match is None:
            continue
        values = []
        match_values = match.groupdict()
        value = ""
        if "min" in match_values and "sub" in match_values\
            and match_values["min"] is not None and match_values["sub"] is not None:
            minuend = float(match_values["min"])
            subtrahend = float(match_values["sub"])
            value = "" + str(round(minuend - subtrahend, 2))
        if "v" in match_values:
            value = match_values["v"]
        return value
    return ""

def export_to_csv(data, file_names, output_file_name, leave_blank=False):
    file_names = list(map(lambda f: os.path.splitext(f)[0], file_names))
    
    csv_string = ""

    csv_header = '"",""'
    for file_name in file_names:
        csv_header += ',"' + file_name + '"'
        
    csv_string += csv_header + "\n"
    
    for test_file in data:
        test_data = data[test_file]
        csv_string += '"' + test_file + '",""'
        status = test_data["status"]
        for file_name in file_names:
            status_str = "NOT_RUN"
            if file_name in status:
                status_str = status[file_name]
            csv_string += ',"' + status_str + '"'
        csv_string += '\n'
        subtests = test_data["subtests"]
        for subtest in subtests:
            csv_string += '"","' + str(subtest) + '"'
            for file_name in file_names:
                values = subtests[subtest]
                value = "NOT_RUN"
                if leave_blank:
                    value = ""
                if file_name in values:
                    value = values[file_name]
                csv_string += ',"' + value + '"'
            csv_string += '\n'

    with open(output_file_name, 'w') as f:
        f.write(csv_string)


    with open('output.json', 'w') as f:
        json.dump(data, f)
        
def parse_regex_file(filename):
    if filename is None:
        return None
    regex_list = []
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()  # remove leading/trailing white spaces
            if not line.startswith('#'):  # ignore lines starting with #
                try:
                    regex = re.compile(line)
                    regex_list.append(regex)
                    print(f"Compiled regex: {regex}")
                except re.error:
                    print(f"Invalid regex: {line}")
    return regex_list

def parse_arguments():
    parser = argparse.ArgumentParser(description='Create csv file from json results file')
    parser.add_argument('-f', '--filter', type=str, help='List of regular expressions to be used to parse values.')
    parser.add_argument('inputs', type=str, nargs="+", help="List of json result files")
    parser.add_argument('output', type=str, help="Output CSV file")

    args = parser.parse_args()
    return args


def main():
    args = parse_arguments()
    #json_files = sys.argv[1:-1]
    #output_file_name = sys.argv[-1]
    json_files = args.inputs
    output_file_name = args.output
    regex_list = parse_regex_file(args.filter)

    #regex_list = [
    #    r"start up delay is (?P<v>[\d\.]+)ms",
    #    r"Playback duration( is)? (?P<min>\d+\.\d+).*expected( track)? duration( is)? (?P<sub>\d+\.\d+)",
    #    r"Total of missing frames is (?P<v>\d*)",
    #    r"Total failure count is (?P<v>\d*)"
    #]
    #regex = None
    leave_blank = False
    if regex_list is not None:
        leave_blank = True
    
    data = read_json_files(json_files)
    collected_data = collect_data(data, regex_list)
    export_to_csv(collected_data, json_files, output_file_name, leave_blank)

if __name__ == "__main__":
    main()
