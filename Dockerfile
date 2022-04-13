############################################# 
# Development go image + air, for live code reload
#############################################
FROM golang:1.18.1 as development
WORKDIR /src

# Install Air
ENV GO111MODULE=off
RUN go get github.com/cosmtrek/air
ENV GO111MODULE=on

# Install dependencies
COPY ./go.mod ./go.sum ./
RUN go mod download

# Copy the code
COPY . .

CMD [ "air" ]


################################################
# Build stage
################################################
FROM golang:1.18.1 as builder
WORKDIR /src

COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ .

RUN CGO_ENABLED=1 go build -ldflags '-extldflags "-static"' -o /release/app


################################################
# Runtime Image
################################################
FROM alpine:3.12 as runtime

WORKDIR /app
COPY --from=builder /release .

CMD ["./app"]
