#!/bin/sh

cd `dirname $0`
echo "[Start]: terraform format"
terraform fmt --recursive
echo "\e[1;34mCompleted\e[0m format\n"

echo "[Start]: terraform validate"
terraform validate

if [ $? -ne 0 ]; then
    echo "Validation failed"
    exit 1
fi


echo "[Start]: tflint"
tflint --config "$(pwd)/.tflint.hcl" --recursive

if [ $? -eq 0 ]; then
    echo "\e[1;32mSuccess!\e[0m Style is valid.\n"
    echo "All check done!"
fi
