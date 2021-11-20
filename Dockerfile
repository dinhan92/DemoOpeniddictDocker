FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
RUN dotnet tool install -g dotnet-ef
ENV PATH $PATH:/root/.dotnet/tools
RUN dotnet ef --version
# RUN apt-get update
# RUN apt-get -y install sqlite3 libsqlite3-dev
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.sln ./
COPY samples/Server/*.csproj ./samples/Server/
COPY tests/*.csproj ./tests/
COPY src/suite/OpenIddict.UI.Suite.Api/*.csproj ./src/suite/OpenIddict.UI.Suite.Api/
COPY src/suite/OpenIddict.UI.Suite.Core/*.csproj ./src/suite/OpenIddict.UI.Suite.Core/
COPY src/openiddict/OpenIddict.UI.Api/*.csproj ./src/openiddict/OpenIddict.UI.Api/
COPY src/openiddict/OpenIddict.UI.Infrastructure/*.csproj ./src/openiddict/OpenIddict.UI.Infrastructure/
COPY src/identity/OpenIddict.UI.Identity.Api/*.csproj ./src/identity/OpenIddict.UI.Identity.Api/
COPY src/identity/OpenIddict.UI.Identity.Core/*.csproj ./src/identity/OpenIddict.UI.Identity.Core/
COPY src/identity/OpenIddict.UI.Identity.Infrastructure/*.csproj ./src/identity/OpenIddict.UI.Identity.Infrastructure/
RUN dotnet restore
COPY . ./

WORKDIR /app/samples/Server
RUN dotnet build -c Release -o out

WORKDIR /app/tests
RUN dotnet build -c Release -o out

# WORKDIR /app/src
# RUN dotnet build -c Release -o out

WORKDIR /app/src/suite/OpenIddict.UI.Suite.Api
RUN dotnet build -c Release -o out

WORKDIR /app/src/suite/OpenIddict.UI.Suite.Core
RUN dotnet build -c Release -o out

WORKDIR /app/src/openiddict/OpenIddict.UI.Api
RUN dotnet build -c Release -o out

WORKDIR /app/src/openiddict/OpenIddict.UI.Infrastructure
RUN dotnet build -c Release -o out

WORKDIR /app/src/identity/OpenIddict.UI.Identity.Api
RUN dotnet build -c Release -o out

WORKDIR /app/src/identity/OpenIddict.UI.Identity.Core
RUN dotnet build -c Release -o out

WORKDIR /app/src/identity/OpenIddict.UI.Identity.Infrastructure
RUN dotnet build -c Release -o out

# WORKDIR /app/samples/Server
# RUN dotnet ef database update -c ApplicationDbContext
# RUN dotnet ef database update -c OpenIddictUIContext
# RUN dotnet ef database update -c OpenIddictUIIdentityContext
# RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
# COPY --from=build-env /app/server.sqlite .
COPY --from=build-env /app/out .
# EXPOSE 5000/tcp
# ENTRYPOINT ["dotnet", "Server.dll"]
ENTRYPOINT ["dotnet", "Server.dll"]