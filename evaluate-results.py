import os
import json
import csv
import sys

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

def collect_data(data):
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
                
                m_value = ""
                t_value = ""
                subtest_data[file_name] = status + ": " + message

    return collected_data
        

def export_to_csv(data, file_names, output_file_name):
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
            csv_string += ',"' + status[file_name] + '"'
        csv_string += '\n'
        subtests = test_data["subtests"]
        for subtest in subtests:
            csv_string += '"","' + str(subtest) + '"'
            for file_name in file_names:
                values = subtests[subtest]
                value = "NOT_RUN"
                if file_name in values:
                    value = values[file_name]
                csv_string += ',"' + value + '"'
            csv_string += '\n'

    with open(output_file_name, 'w') as f:
        f.write(csv_string)


    with open('output.json', 'w') as f:
        json.dump(data, f)


def main():
    json_files = sys.argv[1:-1]
    output_file_name = sys.argv[-1]
    
    data = read_json_files(json_files)
    collected_data = collect_data(data)
    export_to_csv(collected_data, json_files, output_file_name)

if __name__ == "__main__":
    main()
