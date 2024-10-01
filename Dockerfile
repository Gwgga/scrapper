FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy
# python==3.10.12, playwright==1.40.0

# Definir variáveis de ARG e ENV
ARG USER=user
ARG USER_UID=1001
ARG USER_HOME=/home/$USER
ARG USER_DATA_DIR=$USER_HOME/user_data
ARG USER_SCRIPTS_DIR=$USER_HOME/user_scripts
ARG APP_DIR=$USER_HOME/app
ARG APP_HOST=0.0.0.0
ARG APP_PORT=3000
ARG BROWSER_CONTEXT_LIMIT=20
ARG SCREENSHOT_TYPE=jpeg
ARG SCREENSHOT_QUALITY=80

ENV \
	IN_DOCKER=1 \
	USER=$USER \
	USER_UID=$USER_UID \
	USER_HOME=$USER_HOME \
	USER_DATA_DIR=$USER_DATA_DIR \
	USER_SCRIPTS_DIR=$USER_SCRIPTS_DIR \
	APP_DIR=$APP_DIR \
	APP_HOST=$APP_HOST \
	APP_PORT=$APP_PORT \
	BROWSER_CONTEXT_LIMIT=$BROWSER_CONTEXT_LIMIT \
	SCREENSHOT_TYPE=$SCREENSHOT_TYPE \
	SCREENSHOT_QUALITY=$SCREENSHOT_QUALITY

ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Definir informações de metadados sobre a imagem
LABEL org.opencontainers.image.title=Scrapper
LABEL org.opencontainers.image.description="Web scraper with a Playwright setup"
LABEL org.opencontainers.image.url=https://scrapper.dev
LABEL org.opencontainers.image.documentation=https://github.com/Gwgga/scrapper#usage
LABEL org.opencontainers.image.vendor=Gwgga
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source=https://github.com/Gwgga/scrapper

# Definir fuso horário
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependências do sistema
RUN apt-get update

# Clonar o repositório do projeto
RUN git clone https://github.com/Gwgga/scrapper.git $USER_HOME

# Definir diretório de trabalho
WORKDIR $USER_HOME

# Instalar as dependências do Python diretamente do arquivo requirements.txt do repositório clonado
RUN pip install --no-cache-dir -r requirements.txt

# Definir o usuário e permissões apropriadas
RUN useradd -ms /bin/bash -u $USER_UID $USER && \
    chown -R $USER:$USER $USER_HOME
	
USER $USER

# Copiar os arquivos necessários do projeto para o container
RUN mkdir -p $USER_DATA_DIR $USER_SCRIPTS
COPY --chown=$USER:$USER . $USER_HOME

SHELL ["/bin/bash", "-c"]

# Expor a porta do aplicativo
EXPOSE $APP_PORT/tcp

# Configurar o comando de inicialização, interpolando corretamente as variáveis de ambiente
CMD uvicorn --app-dir $APP_DIR main:app --host $APP_HOST --port $APP_PORT
