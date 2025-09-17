while read line;do 

escline=$(echo "$line"|jq -R -s '.')

hdr=$(echo "$OTEL_EXPORTER_OTLP_HEADERS"|sed 's/=/: /g')
curl -s -H "$hdr" -XPOST "${OTEL_EXPORTER_OTLP_ENDPOINT}v1/logs" -H "Content-Type: application/json" \
--data-binary ' {
 "resource_logs": [
   {
     "resource": {
       "attributes": [
         {
           "key": "service.name",
           "value": {
             "stringValue": "'"$OTEL_SERVICE_NAME"'"
           }
         }
       ]
     },
     "scope_logs": [
       {
         "scope": {
           "name": ""
         },
         "log_records": [
           {
         "body": {
           "stringValue": '"$escline"'
         },

             "time_unix_nano": "'$(date +%s000000000)'",
             "observed_time_unix_nano": "'$(date +%s000000000)'",
             "name": "'"$OTEL_SERVICE_NAME"'",
             "severity_text": "INFO"
           }
         ]
       }
     ]
   }
 ]
}' 2>&1 |grep -v partialSuccess
sleep 0.04
done
