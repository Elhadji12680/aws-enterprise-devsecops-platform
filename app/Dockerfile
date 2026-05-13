FROM nginx:1.27-alpine

LABEL maintainer="chimerediouf2000@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/Elhadji12680/aws-enterprise-devsecops-platform"
LABEL org.opencontainers.image.description="Jupiter App — served by nginx on EKS"

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY src/ /usr/share/nginx/html/

RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1

USER appuser

CMD ["nginx", "-g", "daemon off;"]
