#!/bin/bash

# Add custom installation scripts to ISO


cp -R --preserve=mode scripts/* build/releng/airootfs/root/
