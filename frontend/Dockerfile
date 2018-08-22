FROM node:10.9-alpine

RUN apk add --no-cache python make
RUN yarn global add elm@0.18.0

COPY . .

ENTRYPOINT ["make", "serve"]
