steps:
- name: 'gcr.io/cloud-builders/docker'
  args: [ 'build', '-t', '${REPO}/aspnet:1.0.1', '.' ]
images:
- '${REPO}/aspnet:1.0.1'
