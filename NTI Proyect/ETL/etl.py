import json
import pandas as pd
from sqlalchemy import create_engine
import os
import Transformation as trf

#current location
current_location = os.path.dirname(os.path.abspath(__file__))

# Load configuration files
def load_config(file_path):
    with open(file_path, "r") as file:
        return json.load(file)

# Extract data from MySQL
def extract_data(engine, table_name):
    query = f"SELECT * FROM {table_name}"
    return pd.read_sql(query, engine)

# Transform data dynamically based on the mapping
def transform_data(dataframe, validations,transformations):    
    
    # Apply validations and Tranformations
    validated= trf.apply_validations(dataframe, validations)
    if transformations != 0:
        transformed= trf.apply_tranformations(validated, transformations)
        return transformed
    
    
    return validated

# Load data into SQL Server
def load_data(engine, dataframe, table_name):
    dataframe.to_sql(table_name, engine, if_exists="append", index=False)

# Main ETL function
def run_etl():
    # Load configuration and credentials
    mysql_config = load_config(os.path.join(current_location,"config/mysql_credentials.json"))
    sqlserver_config = load_config(os.path.join(current_location,"config/sqlserver_credentials.json"))    
    table_mappings = load_config(os.path.join(current_location,"config/table_mapping.json"))["mappings"]
    
    # MySQL engine
    mysql_conn_str = (
        f"mysql+pymysql://{mysql_config['username']}:{mysql_config['password']}"
        f"@{mysql_config['host']}:{mysql_config['port']}/{mysql_config['database']}"
    )
    mysql_engine = create_engine(mysql_conn_str)
    
    # SQL Server engine
    sqlserver_conn_str = (
        f"mssql+pyodbc://{sqlserver_config['username']}:{sqlserver_config['password']}"
        f"@{sqlserver_config['host']}:{sqlserver_config['port']}/{sqlserver_config['database']}?driver=ODBC+Driver+17+for+SQL+Server"
    )
    sqlserver_engine = create_engine(sqlserver_conn_str)
    
    # Process each table
    for table_mapping in table_mappings:

        # Identification of the process
        source_table = table_mapping["source_table"]
        target_table = table_mapping["target_table"]        
        
        print(f"\n\nProcessing table: {source_table} -> {target_table}")
        
        # Step 1: Extract
        data = extract_data(mysql_engine, source_table)
        print(f"-Extracted {len(data)} rows from {source_table}")

        # divide the process
        validations = table_mapping["validations"]
        transformations=0
        if "transformations" in table_mapping:
            transformations = table_mapping["transformations"]
        
        # Step 2: Transform
        transformed_data = transform_data(data, validations,transformations)
        print(f"-Transformed {len(transformed_data)} rows for {target_table}")
        print(transformed_data)
        
        # # Step 3: Load
        # load_data(sqlserver_engine, transformed_data, target_table)
        # print(f"Loaded {len(transformed_data)} rows into {target_table}")
    
    print("ETL process completed.")

if __name__ == "__main__":  
    run_etl()
