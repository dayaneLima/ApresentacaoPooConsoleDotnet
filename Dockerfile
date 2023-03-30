# Informa ao Docker qual container iremos utilizar
FROM ubuntu:18.04 as base

# Instalacao libs necessarias
RUN apt-get update
RUN apt-get -y install curl wget apt-utils apt-transport-https lsb-release gnupg
RUN apt-get install lsof
RUN apt-get install nano

# Instalacao .net
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y dotnet-sdk-7.0

# Instalação da ferramente do ef para migrations e adição na variável de sistema
RUN dotnet tool install --global dotnet-ef
ENV PATH="${PATH}:/root/.dotnet/tools"

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

# Instalacao tzdata
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Recife
RUN apt-get update
RUN apt-get install -y tzdata

# Cria o diretório codes na raiz do container
RUN mkdir -p /app

# Define o diretório codes como diretório de trabalho
# Isso vai espelhar a pasta codes no diretório debian-core para a pasta codes no container
WORKDIR /app


FROM base AS production
COPY ./src/. ./
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT="production"
CMD dotnet restore TesteDotnet.Api && dotnet publish TesteDotnet.sln -c Release -o dist && dotnet dist/TesteDotnet.Api.dll

FROM base AS development
CMD tail -f /dev/null