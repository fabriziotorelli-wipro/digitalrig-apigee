#!/bin/sh
mkdir -p ../../riglet-logs/digital-platform-architects-apigee
ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml ./apigee_pipeline.yml > ../../riglet-logs/digital-platform-architects-apigee/apigee_pipeline.log
