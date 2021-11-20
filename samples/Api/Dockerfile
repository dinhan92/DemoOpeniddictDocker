FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
RUN apt-get update
RUN apt-get -y install sqlite3 libsqlite3-dev
# RUN apt-get update && apt-get install -y procps
# RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*
#install debugger for NET Core
# RUN apt-get update
# RUN apt-get install -y unzip
# RUN curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l ~/vsdbg
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build-env /app/out .
# EXPOSE 5001/tcp
ENTRYPOINT ["dotnet", "Api.dll"]