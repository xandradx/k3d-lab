FROM python:latest AS BUILD

ADD . /app
RUN pip3 install -r /app/requirements.txt && \
    cd /app/ && \
    mkdocs build

FROM nginx:alpine

COPY --from=BUILD /app/site /usr/share/nginx/html/


