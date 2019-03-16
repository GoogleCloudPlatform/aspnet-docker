package updater

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
)

type MutateOptions struct {
	Src  *regexp.Regexp
	Repl string

	After  *regexp.Regexp
	Before *regexp.Regexp

	Logger Logger
}

func SearchReplace(path string, o *MutateOptions) error {
	o.Logger("%s: replace %q with %q", path, o.Src, o.Repl)
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()

	newLines := [][]byte{}
	scanner := bufio.NewScanner(f)
	foundStart := false
	foundEnd := false
	changes := 0

	if o.After == nil {
		foundStart = true
	}

	for scanner.Scan() {
		line := scanner.Bytes()
		if o.After.Match(line) {
			o.Logger("Found start: %s", line)
			foundStart = true
		}
		if foundStart && o.Before != nil && o.Before.Match(line) {
			o.Logger("Found end:   %s", line)
			foundEnd = true
		}

		if foundStart && !foundEnd && o.Src.Match(line) {
			newLine := o.Src.ReplaceAll(line, []byte(o.Repl))
			newLines = append(newLines, newLine)
			if !bytes.Equal(newLine, line) {
				o.Logger("Old:   %s", line)
				o.Logger("New:   %s", newLine)
				changes++
			}
			continue
		}
		newLines = append(newLines, line)
	}

	if err := scanner.Err(); err != nil {
		return err
	}
	if err := f.Close(); err != nil {
		return err
	}
	if !foundStart {
		return fmt.Errorf("start missing: %s", o.After)
	}

	if changes == 0 {
		return fmt.Errorf("no changes could be made")
	}
	o.Logger("%d lines changed", changes)

	// Trailing newline
	newLines = append(newLines, []byte("\n"))
	// NOTE: does not synchronously write.
	out := bytes.Join(newLines, []byte("\n"))
	if err := ioutil.WriteFile(path, out, os.FileMode(0600)); err != nil {
		return err
	}
	return nil
}
