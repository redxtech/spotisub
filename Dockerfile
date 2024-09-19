FROM python:3.10-slim-bullseye
ARG UID=1000
ARG GID=1000
ARG TZ=Europe/Rome

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gcc \
        locales \
        ffmpeg


RUN sed -i '/it_IT.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG it_IT.UTF-8  
ENV LANGUAGE it_IT:it  
ENV LC_ALL it_IT.UTF-8

RUN groupadd --gid $GID data
RUN useradd --no-log-init --create-home --shell /bin/bash --uid $UID --gid $GID data
USER data
ENV HOME=/home/data
WORKDIR $HOME
RUN mkdir $HOME/.config && chmod -R 777 $HOME
ENV PATH="$HOME/.local/bin:$PATH"
        
WORKDIR $HOME/spotisub
ENV PATH="/home/uwsgi/.local/bin:${PATH}"

COPY requirements.txt .

RUN pip3 install -r requirements.txt

USER root
ENV HOME=/home/data
COPY main.py .
COPY init.py .
COPY spotisub spotisub/
COPY entrypoint.sh .
COPY first_run.sh .
COPY uwsgi.ini .
RUN chmod +x entrypoint.sh
RUN chmod +x first_run.sh

RUN chown -R data:data .


USER data
CMD ["./entrypoint.sh"]
