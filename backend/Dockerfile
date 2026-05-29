FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o umetter ./cmd/server

FROM alpine:3.21
WORKDIR /app
COPY --from=builder /app/umetter .
EXPOSE 8080
CMD ["./umetter"]
