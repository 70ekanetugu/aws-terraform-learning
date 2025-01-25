#!/bin/sh

echo "Start: terraform format"
terraform fmt --recursive
echo "Complete!"

echo "Start: terraform validate"
terraform validate

echo "Start: tflint..."
tflint
