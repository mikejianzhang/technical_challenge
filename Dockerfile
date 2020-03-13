# 1.14-alpine
# pull from the exact digest for security purpose to make sure it is the exact image you want
#
FROM golang@sha256:e484434a085a28801e81089cc8bcec65bc990dd25a070e3dd6e04b19ceafaced AS builder

# Install git for fetching go modules
#
RUN apk update && \
    apk add --no-cache git

# Setup non root user with limit option
#
RUN adduser \
    --disabled-password \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid 80008 \
    mike

WORKDIR $GOPATH/src/main/hello/
COPY . .

RUN go mod download
RUN go mod verify

RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/hello

##
## Build real docker image
##
FROM scratch
COPY --from=builder /go/bin/hello /go/bin/hello

# Copy running user
#
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# User non root user with limited privelege
#
USER mike:mike

# Expose the service by port. Try to use port higher 
# than 1024, so that no need root priveledge to bind
#
EXPOSE 3000

# Export directory
#
VOLUME /tmp

# Set default environment value
#
ENV MESSAGES=Mike

ENTRYPOINT ["/go/bin/hello"]