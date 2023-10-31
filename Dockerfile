# --- NODE BASE ---
FROM node:18-alpine3.16 AS base

ENV ROOT_PROJECT /project
WORKDIR $ROOT_PROJECT
ARG NPM_TOKEN

LABEL version="1.0" \
  description="ecommerce" \
  maintainer1="Nicolas Bermudez <nico@gmail.com>" \
  maintainer2="Cesar Martinez <km.music92@gmail.com>" 

# --- Build Production ---
FROM base AS build

COPY . $ROOT_PROJECT

RUN  : \
  apk update && apk add --no-cache dumb-init; \
  echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > $ROOT_PROJECT/.npmrc; \
  npm i -g @nestjs/cli; \
  npm i -g pnpm; \
  pnpm i --prod; \
  pnpm run build; \
  rm -f .npmrc

# --- PRODUCTION SETUP ---
FROM base AS production

ENV NODE_ENV=production
ENV USER=node

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build $ROOT_PROJECT/node_modules $ROOT_PROJECT/node_modules
COPY --from=build $ROOT_PROJECT/dist $ROOT_PROJECT/dist

USER $USER
EXPOSE $PORT
CMD ["dumb-init", "node", "dist/main.js"]