# Use the Golang base image with Alpine for building the Go application
FROM golang:alpine AS core-builder

# Set the Go proxy to speed up module fetching
ENV GOPROXY=https://www.goproxy.io

# Install CA certificates, and create a non-root user
RUN apk add --no-cache bash ca-certificates \
    && addgroup -S app \
    && adduser -S -G app -h /home/app -s /bin/bash app

# Set the working directory to /home/app in the container
WORKDIR /home/app

# Switch to the "app" user to avoid running as root
USER app

# Copy Go module files and set ownership to "app" user
COPY --chown=app:app go.mod go.sum ./

# Download Go modules and copy the application source code
RUN go mod download && go mod verify

# Copy the application source code
COPY . .

# Build the Go application and install it in /go/bin
RUN go install .

# Use a smaller Alpine image for the final stage
FROM alpine:latest

# Install CA certificates, and create a non-root user
RUN apk add --no-cache ca-certificates \
    && addgroup -S app \
    && adduser -S -G app -h /home/app -s /bin/bash app

# Set the working directory to /home/app in the final image
WORKDIR /home/app

# Switch to the "app" user to avoid running as root
USER app

# Copy the compiled Go binary from the previous build stage to /bin
COPY --chown=app:app --from=core-builder /go/bin/wio /bin/wio

# Set the default command to run the Go application
ENTRYPOINT ["/bin/wio"]
