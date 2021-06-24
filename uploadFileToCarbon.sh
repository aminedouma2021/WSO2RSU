#!/bin/bash

FILE_NAME=$1
CARBON_PATH=$2
FILE_CONTENT=`cat "${FILE_NAME}" | base64`


# Prepare the XML request body itself
read -r -d '' XML_REQUEST << EOM
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:api="http://api.ws.registry.carbon.wso2.org" xmlns:xsd="http://api.ws.registry.carbon.wso2.org/xsd">
   <soap:Header/>
   <soap:Body>
      <api:WSput>
         <!--Optional:-->
         <api:suggestedPath>$CARBON_PATH</api:suggestedPath>
         <!--Optional:-->
         <api:wsResource>
            <xsd:contentFile>$FILE_CONTENT</xsd:contentFile>
            <xsd:mediaType>text/plain</xsd:mediaType>
         </api:wsResource>
      </api:WSput>
   </soap:Body>
</soap:Envelope>
EOM


# Create a temporary file
REQUEST_BODY=$(mktemp)

echo Using temporary file: ${REQUEST_BODY}
echo

echo "$XML_REQUEST"     >> ${REQUEST_BODY}

export http_proxy=""
# Finally, upload the request body
# Based on & inspired by: https://stackoverflow.com/a/45289969/1523342

curl -v --insecure https://wso2am-pattern-1-am-service.wso2apim:9443/services/WSRegistryService.WSRegistryServiceHttpsSoap12Endpoint \
	    -H 'Content-Type: application/soap+xml;charset=UTF-8;action="urn:WSput"' \
	        -H 'MIME-Version: 1.0' \
		    -H 'SOAPAction: ""' \
		    	-H 'Authorization: Basic YWRtaW46YWRtaW4=' \
				--data @${REQUEST_BODY}
# Remove the temporary file.
rm ${REQUEST_BODY}
