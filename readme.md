1. Maar een directory voor je app aan; 
```
> mkdir MyApp
```
2. Ga naar de directory
```
> cd MyApp
```
3. Genereer de applicatie
``` powershell
> docker run -v ${PWD}:/app --workdir /app mcr.microsoft.com/dotnet/core/sdk:3.1 dotnet new webapp --auth Individual
```
4. appsettings.json dit toevoegen;
``` json
 "Kestrel": {
    "EndPoints": {
      "Http": {
        "Url": "http://+:5000"
      }
    }
  }
```
5. startup.cs configureServices 
van;
``` cs
services.AddDbContext<ApplicationDbContext>(options =>
                options.UseSqlite(Configuration.GetConnectionString("DefaultConnection")));
```
naar;
``` cs
var connection = @"Server=db;Database=master;User=sa;Password=Your_password123;";
services.AddDbContext<ApplicationDbContext>(options => options.UseSqlServer(connection));
```
6. app.csproj aanpassen
van;
``` xml
<PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="3.1.4" />
```
naar 
``` xml
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="3.1.4" />
```
7. Even om een bug heenwerken... installeer de ef tools
```
> dotnet tool install --global dotnet-ef
```
Verwijder de migrations directory en maar een nieuwe initiele migration aan
```
dotnet ef migrations add InitialCreate
```
8. Dockerfile toevoegen met als inhoud
``` docker
FROM mcr.microsoft.com/dotnet/core/sdk:3.1
COPY . /app
WORKDIR /app
RUN ["dotnet", "restore"]
RUN ["dotnet", "build"]
EXPOSE 5000/tcp
RUN chmod +x ./entrypoint.sh
RUN dotnet tool install -g dotnet-ef
CMD /bin/bash ./entrypoint.sh
```
9. docker-compose.yml file toevoegen met als inhoud
``` yml
version: "3"
services:
    web:
        build: .
        ports:
            - "5000:5000"
        depends_on:
            - db
    db:
        image: "mcr.microsoft.com/mssql/server:2019-latest"
        environment:
            SA_PASSWORD: "Your_password123"
            ACCEPT_EULA: "Y"
```
8. entrypoint.sh toevoegen met line-endings LF i.p.v. CRLF en als inhoud
``` bash
#!/bin/bash

export PATH="$PATH:/root/.dotnet/tools"
set -e
run_cmd="dotnet run" 
until dotnet ef database update; do
>&2 echo "SQL Server is starting up"
sleep 1
done
>&2 echo "SQL Server is up - executing command"
exec $run_cmd
```
9. Build 
```
> docker-compose build
```
10. Start
``` 
> docker-compose up
```