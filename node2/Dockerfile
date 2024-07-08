FROM ethereum/client-go:alltools-v1.13.13

# Set the working directory in the container
WORKDIR /root

# Copy the required files into the container
COPY password.txt .
COPY genesis.json .
COPY keystore.txt .

# Install any needed packages
RUN apk add --no-cache bash curl jq

# Copy the startup script
COPY start.sh .
RUN chmod +x start.sh

# Expose the necessary ports
EXPOSE 8545 8552 30303

# Set the entrypoint to your startup script
ENTRYPOINT ["./start.sh"]