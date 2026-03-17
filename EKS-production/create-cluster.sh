#!/bin/bash
eksctl create cluster \
  --name samui-portfolio \
  --region ap-southeast-2 \
  --nodegroup-name ko-samui-nodes \
  --node-type t3.small \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
