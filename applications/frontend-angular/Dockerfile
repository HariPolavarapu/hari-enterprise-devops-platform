# =========================================================
# STAGE 1 - BUILD ANGULAR APP
# =========================================================

FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# =========================================================
# STAGE 2 - NGINX
# =========================================================

FROM nginx:alpine
RUN addgroup -S app && adduser -S app -G app

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist/frontend /usr/share/nginx/html
RUN chown -R app:app /usr/share/nginx/html /var/cache/nginx /var/run
USER app

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
