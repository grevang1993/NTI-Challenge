-- Drop the database if it already exists to avoid conflicts and ensure a fresh setup
DROP DATABASE IF EXISTS AlliantCustomer;

-- Create the database
CREATE DATABASE AlliantCustomer;

-- Use the newly created database
USE AlliantCustomer;

-- Create the Locations table
-- This table stores address details for various locations.
CREATE TABLE Locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    street_addr VARCHAR(100),
    municipality VARCHAR(50),
    region_code CHAR(2), -- Two-letter code for regions/states
    postal_code VARCHAR(10) -- Postal code stored as a standard string
);

-- Insert sample locations data
INSERT INTO Locations (street_addr, municipality, region_code, postal_code) VALUES
('123 Elm Street', 'Springfield', 'IL', '62704'),
('456 Oak Avenue', 'Riverside', 'CA', '92501'),
('789 Maple Drive', 'Austin', 'TX', '73301'),
('101 Pine Street', 'Madison', 'WI', '53703'),
('202 Cedar Road', 'Denver', 'CO', '80202');

-- Create the Entities table
-- This table represents either customers or vendors, distinguished by `type_flag`.
CREATE TABLE Entities (
    entity_id INT PRIMARY KEY AUTO_INCREMENT,
    entity_label VARCHAR(100) NOT NULL,
    type_flag CHAR(1), -- 'A' or 'B' to distinguish types of entities (e.g., 'A' for Customer, 'B' for Vendor)
    location_ref INT, 
    contact_info VARCHAR(20),
    FOREIGN KEY (location_ref) REFERENCES Locations(location_id)
);

-- Insert sample entities data
INSERT INTO Entities (entity_label, type_flag, location_ref, contact_info) VALUES
('Alpha Enterprises', 'A', 1, '217-555-1234'),
('Bravo Supplies', 'B', 2, '951-555-4567'),
('Charlie Co.', 'A', 3, '512-555-7890'),
('Delta Corp', 'B', 4, '608-555-1011'),
('Echo Industries', 'A', 5, '303-555-2022');

-- Create the Items table
CREATE TABLE Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    label VARCHAR(100) NOT NULL, -- Name of the item
    source_ref INT, -- Reference to the entity providing the item
    group_ref INT, -- Reference to an entity grouping (could be a distributor, manufacturer, etc.)
    cost VARCHAR(10), -- Cost stored as a string with "$" (e.g., "$12.50")
    qty_available INT, -- Available quantity of the item
    FOREIGN KEY (source_ref) REFERENCES Entities(entity_id),
    FOREIGN KEY (group_ref) REFERENCES Entities(entity_id)
);

-- Insert sample items data
INSERT INTO Items (label, source_ref, group_ref, cost, qty_available) VALUES
('Widget A', 1, 2, '$12.50', 100),
('Gadget B', 2, 3, '$8.75', 200),
('Doodad C', 3, 4, '$15.00', 150),
('Thingamajig D', 4, 5, '$9.50', 250),
('Doohickey E', 5, 1, '$11.25', 175);

-- Create the Batches table
-- This table represents groups of transactions for organizational purposes. 
-- `batch_date` is stored as a Unix timestamp, not a typical date format.
CREATE TABLE Batches (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_date BIGINT NOT NULL, -- Date stored as Unix timestamp
    reference_id INT, -- Reference to an entity involved with the batch
    total_value VARCHAR(15), -- Total value stored as a string with "USD" appended
    FOREIGN KEY (reference_id) REFERENCES Entities(entity_id)
);

-- Insert sample batch data (1 year of data, randomly distributed)
INSERT INTO Batches (batch_date, reference_id, total_value) VALUES
(1704057600, 1, '250 USD'), -- Date as Unix timestamp for '2024-01-01'
(1704144000, 2, '400 USD'),
(1704230400, 3, '300 USD'),
(1704316800, 4, '275 USD'),
(1704403200, 5, '450 USD');

-- Create the Transactions table
-- This table holds individual transactions linked to a batch and an item.
-- The `amount` field is stored as a percentage of the batch in string format (e.g., "50%").
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_ref INT, -- Reference to the batch containing the transaction
    item_ref INT, -- Reference to the item being transacted
    partner_ref INT, -- Reference to an entity involved in the transaction
    qty INT, -- Quantity involved in the transaction
    date_key BIGINT, -- Date as Unix timestamp (not a traditional date type)
    amount VARCHAR(10), -- Transaction amount as a percentage (e.g., "50%")
    FOREIGN KEY (item_ref) REFERENCES Items(item_id),
    FOREIGN KEY (partner_ref) REFERENCES Entities(entity_id),
    FOREIGN KEY (batch_ref) REFERENCES Batches(batch_id)
);

-- Insert sample transactions data
INSERT INTO Transactions (batch_ref, item_ref, partner_ref, qty, date_key, amount) VALUES
(1, 1, 2, 10, 1704057600, '50%'),
(1, 2, 3, 5, 1704057600, '50%'),
(2, 3, 4, 15, 1704144000, '60%'),
(2, 4, 5, 10, 1704144000, '40%'),
(3, 5, 1, 20, 1704230400, '75%'),
(1, 1, 2, 10, 1704057600, '50%'),
(1, 2, 3, 5, 1704057600, '30%'),
(2, 3, 4, 15, 1704144000, '60%'),
(2, 4, 5, 10, 1704144000, '40%'),
(3, 5, 1, 20, 1704230400, '75%'),
(3, 1, 2, 7, 1704316800, '20%'),
(3, 2, 3, 8, 1704403200, '40%'),
(4, 3, 4, 12, 1704489600, '35%'),
(4, 4, 5, 9, 1704576000, '50%'),
(5, 5, 1, 18, 1704662400, '55%'),
(5, 1, 2, 6, 1704748800, '25%'),
(5, 2, 3, 14, 1704835200, '65%');


-- Create the Calendar table
-- This table provides a simple calendar reference with each day as an auto-incremented ID.
-- The `readable_date` field is in standard date format.
CREATE TABLE Calendar (
    date_key INT PRIMARY KEY AUTO_INCREMENT, -- Unique date ID (auto-incremented)
    readable_date DATE NOT NULL -- Standard date format (e.g., "2024-01-01")
);

-- Populate the Calendar table with dates for the year (sample data)
INSERT INTO Calendar (readable_date) VALUES 
('2024-01-01'), ('2024-01-02'), ('2024-01-03'), ('2024-01-04'), ('2024-01-05');
