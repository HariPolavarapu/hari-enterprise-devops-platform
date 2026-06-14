# =========================================================
# STAGE 1 - BUILD
# =========================================================

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY . .

RUN dotnet restore

RUN dotnet publish -c Release -o /app/publish

# =========================================================
# STAGE 2 - RUNTIME
# =========================================================

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app
RUN addgroup --system app && adduser --system --ingroup app app

COPY --from=build /app/publish .
USER app

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "payroll.dll"]
