/*

usage:

go run update_versions.go 1.0=1.0.13 2.1=2.1.504
*/

package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/tstromberg/aspnet-docker/tools/updater"
)

func updateVersion(tag string, version string) error {
	steps := []updater.Step{
		&updater.ASPNetCoreVersion{},
		&updater.CloudBuildVersion{},
		/*		GlobalJSONVersion,
				IntegrationTestsVersion,
				StructuralTestsVersion,
				DockerFileVersion,
				BuildRuntimesTagVersion, */
	}
	return updater.Run(steps, &updater.StepConfig{Target: tag, Value: version})
}

func main() {
	for _, a := range os.Args[1:] {
		if !strings.Contains(a, "=") {
			panic(fmt.Sprintf("Argument has no equal sign: %s", a))
		}
		parts := strings.Split(a, "=")
		fmt.Printf("parts: %v\n", parts)
		err := updateVersion(parts[0], parts[1])
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}
}
