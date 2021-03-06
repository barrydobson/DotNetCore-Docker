# Build image
FROM microsoft/dotnet:sdk AS builder
WORKDIR /sln

ONBUILD COPY ./*.sln  ./

# Copy the main source project files
ONBUILD COPY src/*/*.csproj ./
ONBUILD RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done

# Copy the test project files
ONBUILD COPY test/*/*.csproj ./
ONBUILD RUN for file in $(ls *.csproj); do mkdir -p test/${file%.*}/ && mv $file test/${file%.*}/; done 

ONBUILD RUN dotnet restore

ONBUILD COPY ./test ./test
ONBUILD COPY ./src ./src
ONBUILD RUN dotnet build -c Release --no-restore

ONBUILD RUN find ./test -name '*.csproj' -print0 | xargs -L1 -0 dotnet test -c Release --no-build --no-restore