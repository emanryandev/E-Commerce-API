# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy solution and all project files to restore dependencies
COPY ["E-Commerce.slnx", "./"]
COPY ["E-Commerce/E-Commerce.API.csproj", "E-Commerce/"]
COPY ["E-Commerce.Application/E-Commerce.Application.csproj", "E-Commerce.Application/"]
COPY ["E-Commerce.Domain/E-Commerce.Domain.csproj", "E-Commerce.Domain/"]
COPY ["E-Commerce.Infrastructure/E-Commerce.Infrastructure.csproj", "E-Commerce.Infrastructure/"]

# Restore packages
RUN dotnet restore "E-Commerce/E-Commerce.API.csproj"

# Copy the rest of the source code
COPY . .

# Build and Publish the API project
WORKDIR "/src/E-Commerce"
RUN dotnet build "E-Commerce.API.csproj" -c Release -o /app/build
RUN dotnet publish "E-Commerce.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime environment
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/publish .
RUN mkdir -p /app/Files
ENTRYPOINT ["dotnet", "E-Commerce.API.dll"]
