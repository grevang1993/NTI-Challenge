# Use the MySQL image optimized for ARM64 (suitable for M1 chip)
FROM mysql:8.1

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=alliantcustomer
ENV MYSQL_USER=root

# Copy initialization SQL script into the container
COPY init.sql /docker-entrypoint-initdb.d/

# Expose default MySQL port
EXPOSE 3307
