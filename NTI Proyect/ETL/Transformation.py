import re
import pandas as pd
from datetime import datetime

def apply_validations(dataframe, validations):
    try:
        dataframe = pd.DataFrame(dataframe)
        
        for column, validation_rule in validations.items():
            
            if column not in dataframe.columns:
                raise ValueError(f"Column '{column}' not found in the DataFrame.")
            
            dataframe = dataframe.drop_duplicates()

            if "IS NOT NULL" in validation_rule:
                dataframe = dataframe.dropna(subset=[column])

            if ">" in validation_rule or ">=" in validation_rule:
                threshold = re.split(r"(>=|>)", validation_rule)
                threshold = float(threshold[-1])

                if ">=" in validation_rule:
                    dataframe = dataframe[dataframe[column] >= threshold]
                elif ">" in validation_rule:
                    dataframe = dataframe[dataframe[column] > threshold]

            if "LENGTH" in validation_rule:
                max_length = int(re.search(r"LENGTH\((.+)\) <= (\d+)", validation_rule).group(2))                
                dataframe = dataframe[dataframe[column].str.len() <= max_length]

            if "REGEXP_MATCH" in validation_rule:
                pattern = re.search(r"REGEXP_MATCH\((.+), '(.+)'\)", validation_rule).group(2)
                dataframe = dataframe[dataframe[column].astype(str).str.match(pattern)]

            if "IN" in validation_rule:
                valid_values = re.search(r"IN \((.+)\)", validation_rule).group(1)
                valid_values = [val.strip().strip("'") for val in valid_values.split(",")]
                dataframe = dataframe[dataframe[column].isin(valid_values)]
            
            
    except Exception as e:
        print((f"validation '{e}' "))

    return dataframe



def apply_tranformations(dataframe, transformation):
    try:
        # dataframe = pd.DataFrame(dataframe)
        
        for column, transformation_rule in transformation.items():
            print(f"Column '{column}': '{transformation_rule}'")

            if column not in dataframe.columns:
                raise ValueError(f"Column '{column}' not found in the DataFrame.")
            
            if "FROM_UNIXTIME" in transformation_rule:
                dataframe[column] = pd.to_datetime(dataframe[column], unit='s')
                dataframe[column] = dataframe[column].dt.strftime('%m-%d-%Y %H:%M:%S')

            if "to_datetime" in transformation_rule:
                dataframe[column] = pd.to_datetime(dataframe[column])
                dataframe[column] = dataframe[column].dt.strftime('%m-%d-%Y %H:%M:%S')
            
            if "UPPER" in transformation_rule:
                dataframe[column] = dataframe[column].str.upper()

            if "::" in transformation_rule:
                cast_type = transformation_rule.split("::")[1].strip().lower()
                if cast_type == "money":
                    dataframe[column] = dataframe[column].str.replace("$", "").astype(float)

            if "CAST" in transformation_rule:
                cast_type = transformation_rule.split(" AS ")[1].strip().lower()
                if "nvarchar" in cast_type:
                    dataframe[column] = dataframe[column].astype(str)
                elif "money" in cast_type:
                    dataframe[column] = dataframe[column].str.replace("$", "").str.replace("USD", "").astype(float)
                elif "float" in cast_type:
                    dataframe[column] = dataframe[column].str.replace("$", "").str.replace("%", "").astype(float)
                    if "/ 100" in cast_type:
                        dataframe[column] = dataframe[column] /100
                    
           

            if "CASE" in transformation_rule:                  
                case_condition = transformation_rule.split("WHEN")[1].split("THEN")
                condition, output = case_condition[0].strip(), case_condition[1].split("ELSE")[0].strip()
                default_output = transformation_rule.split("ELSE")[1].split("END")[0].strip()
                dataframe[column] = dataframe[column].apply(lambda x: output if eval(condition.replace("type_flag", f"'{x}'")) else default_output)
           

            
            

    except Exception as e:
        print((f"transformation: '{e}' "))

    return dataframe

