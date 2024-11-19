# Use the official .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

# Set build arguments (you can override these at build time)
ARG BUILD_CONFIGURATION=Release
ARG DOTNET_VERSION=7.0

# Set the working directory
WORKDIR /src

# Copy the project files into the container
COPY /workload-type/api/dotnet/*.csproj ./workload-type/api/dotnet/

# Restore dependencies
RUN dotnet restore /workload-type/api/dotnet/

# Copy the rest of the application code
COPY /workload-type/api/dotnet/ /workload-type/api/dotnet/

# Build the application
RUN dotnet build /workload-type/api/dotnet/ -c $BUILD_CONFIGURATION --no-restore

# Publish the application
RUN dotnet publish /workload-type/api/dotnet/ -c $BUILD_CONFIGURATION -o /app --no-restore

# Use a lightweight runtime image for running the application
FROM mcr.microsoft.com/dotnet/aspnet:$DOTNET_VERSION

# Set environment variables (override as needed)
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_VERSION=$DOTNET_VERSION
ENV ASPNETCORE_URLS=http://+:5000

# Set the working directory in the runtime image
WORKDIR /app

# Copy the built application from the build stage
COPY --from=build /app ./

# Expose the port the application runs on
EXPOSE 5000

# Start the application
ENTRYPOINT ["dotnet", "YourProject.dll"]
