package qa_common

import (
	"io/ioutil"
	"strings"
)

const SCRIPT_DIR = "./qa_scripts/"

var disallowed_commands = []string{
	// TODO disallow all commands that blocks thread from serving

	"sudo", // disallow commands called with root's permission
	"htop",
}

var Valid_scripts = map[string]string{}

// Returns true if command is disallowed to execute
// script execution and execution of binary files are disallowed by default
func Check_disallowed(command string) bool {

	path_arr := strings.Split(command, "/")
	// command is path to a script or executable
	// e.g /erigon_dir/build/bin/erigon
	// /some/path/to/script.sh
	// ./script.sh
	if len(path_arr) > 1 {
		return true
	}

	for _, d_command := range disallowed_commands {
		if d_command == command {
			return true
		}
	}

	return false
}

// Sets scripts name without extension to scripts path
// e.g kill_erigon.sh => { "kill_erigon" : "./qa_scripts/kill_erigon.sh" }
func Read_qa_scripts() {
	items, _ := ioutil.ReadDir(SCRIPT_DIR)

	for _, item := range items {
		if item.IsDir() {
			continue
		} else {
			file_name := item.Name()
			command := file_name[:len(file_name)-3]

			Valid_scripts[command] = SCRIPT_DIR + file_name
		}
	}

}
