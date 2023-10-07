FROM node:18-alpine3.16 AS base

ENV DIR /project
WORKDIR $DIR
COPY package*.json $DIR

RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR $DIR
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

FROM base AS dev

ENV NODE_ENV=development


COPY tsconfig*.json $DIR
COPY src $DIR/src

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build $DIR/node_modules $DIR/node_modules
COPY --from=build $DIR/dist $DIR/dist



EXPOSE $PORT
CMD ["pnpm", "run", "start:dev"]

FROM base AS build

RUN apk update && apk add --no-cache dumb-init

COPY package*.json $DIR
COPY --from=dependencies $DIR/node_modules ./node_modules

COPY tsconfig*.json $DIR
COPY src $DIR/src

RUN pnpm run build
RUN pnpm prune --production

FROM base AS production

ENV NODE_ENV=production
ENV USER=node

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build $DIR/node_modules $DIR/node_modules
COPY --from=build $DIR/dist $DIR/dist

USER $USER
EXPOSE $PORT
CMD ["dumb-init", "node", "dist/main.js"]