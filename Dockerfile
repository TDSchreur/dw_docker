FROM mcr.microsoft.com/dotnet/core/sdk:3.1
COPY . /app
WORKDIR /app
RUN ["dotnet", "restore"]
RUN ["dotnet", "build"]
EXPOSE 5000/tcp
RUN chmod +x ./entrypoint.sh
RUN dotnet tool install -g dotnet-ef
CMD /bin/bash ./entrypoint.sh