# Use the official Azure SQL Edge image
FROM mcr.microsoft.com/azure-sql-edge:latest


# Fix permissions for sqlservr and sqlcmd binaries
RUN chmod +x /opt/mssql/bin/sqlservr && \
    chmod +x /opt/mssql-tools/bin/sqlcmd

# Set environment variables for Azure SQL Edge
ENV SA_PASSWORD=StrongPassword123
ENV ACCEPT_EULA=1

# Expose the SQL Server port
EXPOSE 1433

# Copy initialization SQL script into the container
COPY init.sql /init.sql/
# COPY init.sql /docker-entrypoint-initdb.d/

# Run the initialization script after starting the server
CMD /opt/mssql/bin/sqlservr & sleep 30 && /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -i /init.sql


