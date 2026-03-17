#!/bin/bash
eksctl scale nodegroup \
  --cluster samui-portfolio \
  --region ap-southeast-2 \
  --name ko-samui-nodes \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3
