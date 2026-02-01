# Fitness Coach AI

Personal fitness coach app that can track your workouts and analyze and provide insights and workout plans to achieve your fitness goals. Built with Flutter for UI, Go for backend, Supabase for DB and Auth, Python for AI microservices and gRPC for communication between Go and Python.

## Install the Necessary Packages

All the necessary Python pacakges are added to the [requirements.txt](/backend/services/requirements.txt) file. Run the below command to install all the packages from this file.

```bash
pip3 install -r requirements.txt
```

The below commands installs the necessary Go gRPC packages.

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

Add the installed Go protoc-gen-go package to PATH

```bash
export PATH="$PATH:$(go env GOPATH)/bin"
```

The below commands gets the necessary Go project dependencies

```bash
go get github.com/gin-gonic/gin
go get github.com/jackc/pgx/v5
go get github.com/joho/godotenv
go get github.com/lestrrat-go/httprc/v3
go get github.com/lestrrat-go/jwx/v3
go get github.com/lestrrat-go/jwx/v3/jwk
go get github.com/lestrrat-go/jwx/v3/jwt
go get google.golang.org/grpc
go get google.golang.org/protobuf
```

## Generate the gRPC Files

Run the below command from the /backend folder to generate the Python gRPC files.

```bash
python3 -m grpc_tools.protoc -I./proto --python_out=./services/proto --grpc_python_out=./services/proto ./proto/service.proto
```

Run the below command from the /backend folder to generate the Go gRPC files.

```bash
protoc --proto_path=./proto --go_out=./api/proto --go_opt=paths=source_relative --go-grpc_out=./api/proto --go-grpc_opt=paths=source_relative ./proto/coach.proto
```

## Run the gRPC & Gin servers

```bash
python3 server.py
```

```bash
go run .
```