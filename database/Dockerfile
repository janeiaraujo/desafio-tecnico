# Custom PostgreSQL initialization
FROM postgres:15.8-alpine

# Set environment variables
ENV POSTGRES_DB=desafio
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=secure_password

# Expose port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB

# Use default postgres entrypoint