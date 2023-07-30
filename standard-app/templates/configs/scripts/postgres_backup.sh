#!/bin/bash
DATE=$(date +%d_%m)
DATABASES=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://sqladmin.googleapis.com/v1/projects/$PROJECT_ID/instances/$INSTANCE_ID/databases" | \
  python3 -c "import sys, json; [print(database['name']) for database in json.load(sys.stdin)['items']]")

for database in $DATABASES
do
  echo '{
        "exportContext":
          {
            "fileType": "SQL",
            "uri": "gs://'$BUCKET_NAME'/'$DUMP_PATH'/'$DATE'/'$database'",
            "databases": "'$database'",
            "offload": false
          }
        }' > /tmp/backup_request.json

  operationUrl=$(curl -s -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" \
      -H "Content-Type: application/json; charset=utf-8" -d @/tmp/backup_request.json \
      "https://sqladmin.googleapis.com/v1/projects/$PROJECT_ID/instances/$INSTANCE_ID/export" | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['selfLink'])")

  # Catch export completion status
  operationStatus=$(curl -s -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" $operationUrl | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")

  while [ "$operationStatus" != "DONE" ]
  do 
    sleep 10
    echo "Exporting $database..."
    operationStatus=$(curl -s -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" $operationUrl | \
      python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")
  done
done



