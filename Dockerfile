FROM golang:latest

LABEL maintainer="Mohammed Rampurawala"

WORKDIR /app

COPY ./go-app /app


ENV DEMO_APP_ADDR=8000


RUN make build

#RUN make run
EXPOSE 8000

CMD ["./demo.bin"]
