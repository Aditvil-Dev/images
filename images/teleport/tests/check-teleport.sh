#!/bin/bash

container_name="teleport"
trap "docker logs ${container_name} && docker rm -f ${container_name}" EXIT
# Function to generate the teleport.yaml configuration file
generate_teleport_config() {
    echo "Generating teleport.yaml configuration file..."
    docker run --rm --entrypoint="teleport" $IMAGE_NAME configure --roles=proxy,auth > /data/teleport.yaml
    chmod 777 /data

    if [ -f /data/teleport.yaml ]; then
        echo "teleport.yaml configuration file generated successfully."
    else
        echo "Failed to generate teleport.yaml configuration file."
        exit 1
    fi
}

# Function to start the Teleport container with configuration file
start_teleport() {
    echo "Running the Teleport container with configuration file..."
    docker run -d --name $container_name -p 3080:3080 \
        -v "${VOLUME_NAME}":/etc/teleport \
        $IMAGE_NAME

    # Wait for the container to start
    sleep 10

    # Check if the container is running
    if [ "$(docker ps -q -f name=$container_name)" ]; then
        echo "Teleport container started successfully."
    else
        echo "Failed to start Teleport container."
        exit 1
    fi
}

# Function to check connectivity to the Teleport service
check_connectivity() {
    curl() {
        docker run --network container:"${container_name}" cgr.dev/chainguard/curl "$@"
    }

    echo "Checking connectivity to Teleport web interface..."
    curl -s -o /dev/null -w "%{http_code}" -k https://localhost:3080 > /dev/null

    if [ $? -eq 0 ]; then
        echo "Teleport web interface is reachable."
    else
        # get the logs of the container
        docker logs teleport
        echo "Cannot reach Teleport web interface."
        exit 1
    fi
}

# Main script execution
generate_teleport_config
start_teleport
check_connectivity

# steps we cannot automate:
# 1. We should create a user (we can do that) and go to the invite link to create a password for the user (which we cannot automate)
# 2. Use `tsh login` that requires prompt to enter the password (which we cannot automate)

echo "All tests passed successfully."
