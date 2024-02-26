FROM node:hydrogen-slim

RUN apt update && \
    apt install git-all -y && \
    apt install python3-full -y && \
    apt install python3-pip -y 
RUN npm install -g @techdocs/cli
RUN pip3 install mkdocs --break-system-packages
RUN pip3 install mkdocs-techdocs-core --break-system-packages

COPY ./run.sh .

