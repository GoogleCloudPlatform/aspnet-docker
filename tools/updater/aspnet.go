package updater

import (
	"fmt"
	"io/ioutil"
	"regexp"
	"strings"

	yaml "gopkg.in/yaml.v2"
)

var (
	aspNetCorePath = "aspnetcore.yaml"
	cloudBuildPath = "builder/cloudbuild.yaml"
)

// cloudBuildSteps represents the steps included in aspnetcore.yaml
type cloudBuildSteps struct {
	Steps []cloudBuildStep `yaml:"steps"`
}

// cloudBuildStep represents a single YAML step
type cloudBuildStep struct {
	Name string
	Args []string
}

// ASPNetCoreVersion updates
type ASPNetCoreVersion struct{}

// Check that the value is in the version map
func (*ASPNetCoreVersion) Check(c *StepConfig) error {
	return checkCloudBuildVersionMap(aspNetCorePath, aspNetCoreBucket(c.Value), c)
}

func (*ASPNetCoreVersion) Apply(c *StepConfig) error {
	return updateCloudBuildVersionMap(aspNetCorePath, aspNetCoreBucket(c.Value), c)
}

// aspNetCoreBucket returns the GCR bucket location for an aspnetcore version
func aspNetCoreBucket(version string) string {
	return fmt.Sprintf("gcr.io/google-appengine/aspnetcore:%s", version)
}

type CloudBuildVersion struct{}

func (*CloudBuildVersion) Check(c *StepConfig) error {
	return checkCloudBuildVersionMap(cloudBuildPath, fmt.Sprintf("%s=aspnetcore:%s", c.Value, c.Target), c)
}
func (*CloudBuildVersion) Apply(c *StepConfig) error {
	return updateCloudBuildVersionMap(cloudBuildPath, fmt.Sprintf("%s=aspnetcore:%s", c.Value, c.Target), c)
}

func checkCloudBuildVersionMap(path string, newValue string, c *StepConfig) error {
	f, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}
	ys := &cloudBuildSteps{}
	err = yaml.Unmarshal(f, ys)
	if err != nil {
		return err
	}
	if len(ys.Steps) == 0 {
		return fmt.Errorf("no steps found in %s", path)
	}

	seen := []string{}
	for _, a := range ys.Steps[0].Args {
		if !strings.Contains(a, "=") {
			continue
		}
		parts := strings.Split(a, "=")
		if len(parts) != 2 {
			return fmt.Errorf("unexpected data: %v", parts)
		}
		tag := parts[0]
		value := parts[1]
		seen = append(seen, tag)
		if tag == c.Value {
			if value != newValue {
				return fmt.Errorf("%s has unexpected value: %s", tag, value)
			}
			c.Logger("Found: %s", a)
			return nil
		}
	}
	return fmt.Errorf("%s not in %s version map, found: %v", c.Value, path, seen)
}

func updateCloudBuildVersionMap(path, newValue string, c *StepConfig) error {
	return SearchReplace(path, &MutateOptions{
		Src:    regexp.MustCompile(fmt.Sprintf(`- '%s[\.\d]+=[a-z.*]:[\.\d]+'`, c.Target)),
		Repl:   fmt.Sprintf("- '%s=%s'", c.Value, newValue),
		Before: regexp.MustCompile(`^-`),
		After:  regexp.MustCompile(`^\s+- '--version-map'`),
		Logger: c.Logger,
	})
}
