# INSTALL JQ - START
IS_JQ_INSTALLED=$(which jq | wc -l)
if [ $IS_JQ_INSTALLED -eq 0 ]; then
	echo "jq is required to install, please confirm Y/N to install (default Y): "
	read -r CONFIRM_JQ
	if [ "$CONFIRM_JQ" == "Y" ] || [ "$CONFIRM_JQ" == "y" ] || [ "$CONFIRM_JQ" == "" ]; then
    	if [ "$DISTRO" == "Ubuntu" ] || [ "$DISTRO" == "Debian" ]; then
        	sudo apt-get update
        	sudo apt-get install jq -y
    	else
        	echo "Unable to continue. Please install jq manually before proceeding."; exit 131
    	fi
	else
    	echo "Unable to continue without jq. Please install jq before proceeding."; exit 131
	fi
fi

# INSTALL JQ - END

# INSTALL GO - START
IS_GO_INSTALLED=$(which go | wc -l)
if [ $IS_GO_INSTALLED -eq 0 ]; then
	echo "jq is required to install, please confirm Y/N to install (default Y): "
	read -r CONFIRM_GO
	if [ "$CONFIRM_GO" == "Y" ] || [ "$CONFIRM_GO" == "y" ] || [ "$CONFIRM_GO" == "" ]; then
    	if [ "$DISTRO" == "Ubuntu" ] || [ "$DISTRO" == "Debian" ]; then
        	sudo apt-get update
# DOWNLOAD GO BINARY
        	wget -q https://d1.google.com/go/go1.17.linux-amd64.tar.gz
# EXTRACT THE ARCHIVE
        	tar -xf go1.17.linux-amd64.tar.gz
# MOVE GO TO /usr/local DIRECTORY
        	sudo mv go /usr/local

# SET GO ENVIRONMENT VARIABLES
        	echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        	echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc

# RELOAD THE bashrc FILE
        	source ~/.bashrc
# CLEAN UP THE DOWNLOADED ARCHIVE
        	rm go1.17.linux-amd64.tar.gz
        	echo "Go has been installed successfully!"
    	else
        	echo "Unable to continue. Please install GO manually before proceeding."; exit 131
    	fi
	else
    	echo "Unable to continue without GO. Please install GO before proceeding."; exit 131
	fi
else
	echo "Go is already installed"
fi
# INSTALL GO - END

NR_INTEGRATIONS_DIR="/var/db/newrelic-infra/newrelic-integrations/bin/"

files=()

# FIND ALL FILES IN THE DIRECTORY
while IFS= read -r -d '' file; do
	# add each file name to the array
	files+=("$file")
done < <(find "$NR_INTEGRATIONS_DIR" -type f -print0)

# CREATE JSON ARRAY
json="["
for ((i = 0; i< ${#files[@]}; i++)); do
	INTEGRATION_VERSION=$(${files[$i]} -show_version)
	INTEGRATION_NAME=$(basename ${files[$i]})
	echo $INTEGRATION_NAME
	# ADD FILE NAMES TO JSON ARRAY
	json+="\"{ version: $INTEGRATION_VERSION, language: $INTEGRATION_NAME }\""

	# ADD COMMA IF IT'S NOT THE LAST ELEMENT
	if [[ $i -lt $((${#files[@]} - 1)) ]]; then
    	json+=", "
	fi
done
json+="]"


echo "$json" > nr_integrations.json

# SEND RESPONSE TO NR_SERVER
URL="http://54.152.4.189:8000/agents/?guid=MzE0MDA4fEFQTXxBUFBMSUNBVElPTnwzNjAyNjk1MQ"
DATA=$(cat ./nr_integrations.json)
echo $DATA
curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL"