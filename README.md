parameters for getconfig and apply

```
aws_public_key ?=janitha.jayaweera.525546773638
tag-environment ?=janitha
```

```
Usage:
  make <target>

Targets:
  apply                Create infra takes variable aws_public_key and tag-environment
  destroy              Destroy infra, must confirm with yes
  getconfig            Copy kubeconfig to local given master_0 and aws_public_key, assumes user file location
  output               Show output of apply 
  help                 Show this help
```
