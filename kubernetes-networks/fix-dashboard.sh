#!/bin/sh
kubectl create role access-secrets --verb=get,list,watch,update,create --resource=secrets 
kubectl create rolebinding --role=access-secrets default-to-secrets --serviceaccount=kube-system:default 
kubectl create clusterrolebinding kube-system-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
