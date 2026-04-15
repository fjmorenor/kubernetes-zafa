#!/bin/bash
set -euo pipefail

HOST_PROJECT="landing-host-zafa"
BUCKET_NAME="tf-state-landing-zafa"
REGION="europe-west1"

echo "==> Creando bucket GCS"

gcloud storage buckets create gs://bucket-landing-zafa-2026 \
--project=$HOST_PROJECT
--location=$REGION
--uniform-bucket-level-access

echo "==> Habilitando versionado"
gcloud storage buckets update gs://BUCKET_NAME --versioning

echo "==> Bucket listo: gs://$BUCKET_NAME"