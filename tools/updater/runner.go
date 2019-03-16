package updater

import (
	"fmt"
	"reflect"
	"strings"
)

// Steps are a standardized interface to a reliably make changes to a system
type Step interface {
	Check(*StepConfig) error
	Apply(*StepConfig) error
}

type Logger func(format string, args ...interface{})

// StepConfig are options to steps: intended to be as generic as possible.
type StepConfig struct {
	// Logger is a callback for logging.
	Logger Logger
	// Target is a string representation of an object to update (required)
	Target string
	// Optional value to update the target with (optional)
	Value string
}

// defaultLogger is a default logging implementation.
func defaultLogger(format string, args ...interface{}) {
	fmt.Printf("  > "+format+"\n", args...)
}

// Run executes a series of steps, with console output.
func Run(steps []Step, c *StepConfig) error {
	var failures []error
	if c.Logger == nil {
		c.Logger = defaultLogger
	}

	for i, s := range steps {
		if i > 0 {
			fmt.Println("")
		}
		name := stepName(s)
		fmt.Printf("[%d/%d] %s\n", i+1, len(steps), name)
		err := s.Check(c)
		if err == nil {
			fmt.Println("  ✔️ pre-check:  passed")
			continue
		} else {
			fmt.Printf("  ✖️️ pre-check:  %s\n", err)
		}

		if len(failures) > 0 {
			fmt.Println("  ⏳apply:      skipping (previous step failed)")
			continue
		}

		err = s.Apply(c)
		if err != nil {
			fmt.Printf("  ✖️ apply:      %v\n", err)
			failures = append(failures, fmt.Errorf("%s apply: %v", name, err))
			continue
		} else {
			fmt.Println("  ✔️ apply:      successful")
		}

		err = s.Check(c)
		if err != nil {
			fmt.Printf("  ✖ post-check: %v\n", err)
			failures = append(failures, fmt.Errorf("%s post-check: %v", name, err))
			continue
		}
		fmt.Println("  ✔️ post-check: passed")
	}

	fmt.Println("")
	if len(failures) == 1 {
		return fmt.Errorf("error: %v", failures[0])
	}
	if len(failures) > 1 {
		return fmt.Errorf("errors: %v", failures)
	}
	return nil
}

// stepName returns the name of a function, using reflection.
func stepName(i interface{}) string {
	return strings.Replace(strings.Replace(reflect.TypeOf(i).String(), "*", "", 1), "updater.", "", 1)
	//	return runtime.FuncForPC(reflect.ValueOf(i).Pointer()).Name()
}
