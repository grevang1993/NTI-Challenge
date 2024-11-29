--**************** Query Report***********

-- I took the structure from the target database and created it in Postgresql 
-- to have an idea of how the query is going to behave.

-- With the query report, I divide the problem into different stages, which gives 
-- me a better understanding of what I need to accomplish my goals. 
-- I use CTEs to work with the data: 

-- First CTE CustomerOrders: I organized the necessary information by calculating 
-- the total and average orders, using filters in the WHERE and HAVING clauses.

-- Second CTE DistinctProducts: I keep track of the number of unique products 
-- ordered by each customer over the course of a year.

-- In the end, I gathered all this information to create the necessary report.

WITH CustomerOrders AS (
    SELECT 
        o.CustomerID,
        COUNT(o.OrderID) AS TotalOrders,
        COUNT(o.OrderID) / 12 AS AvgOrdersPerMonth
    FROM Orders o
    WHERE o.OrderDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY o.CustomerID
    HAVING COUNT(o.OrderID) >= 5
), DistinctProducts AS (
    SELECT 
        o.CustomerID,
        COUNT(DISTINCT od.ProductID) AS DistinctProductCount
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY o.CustomerID
)

SELECT 
    c.CustomerID,
    c.CompanyName AS CustomerName,
    co.AvgOrdersPerMonth,
    dp.DistinctProductCount
FROM CustomerOrders co
INNER JOIN DistinctProducts dp ON co.CustomerID = dp.CustomerID
INNER JOIN Customers c ON co.CustomerID = c.CustomerID
ORDER BY co.AvgOrdersPerMonth DESC;


 Optimization Techniques to this report:
Indexes:
    Ensure there are indexes on OrderDate, CustomerID (in Orders), and ProductID (in Order Details).
    Leverage existing indexes on Customers table for fast lookups.

Efficient Filtering:
    Use DATEADD for date filtering to minimize the range of data processed.

Aggregations:
    Use COUNT(DISTINCT ...) judiciously for distinct product counts.


--**************** Stored Procedure ***********
-- The idea with the parameter @StartDate and @EndDate is specify the range for filtering orders based on OrderDate.
-- @CategoryID (optional): Filter by product category if provided. If not, all categories are included.

-- The logic here is Joins the next tables (Orders, Order Details, Products, Categories, and Customers tables)
-- using as a Filters records by OrderDate within the specified range and optionally by CategoryID and
-- using a few Aggregates funtios to grouping the information in the way that we needed


CREATE PROCEDURE usp_GetCustomerPurchaseReport
    @StartDate DATE,          -- Start of the date range
    @EndDate DATE,            -- End of the date range
    @CategoryID INT = NULL    -- Optional parameter for product category
AS
BEGIN
    SET NOCOUNT ON;

    -- Fetch customers who purchased products in the given date range and optional category
    SELECT 
        c.CustomerID,
        c.CompanyName AS CustomerName,
        c.ContactName,
        c.ContactTitle,
        c.City,
        c.Country,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        COUNT(DISTINCT od.ProductID) AS TotalProductsPurchased,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalAmountSpent
    FROM 
        Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    INNER JOIN Products p ON od.ProductID = p.ProductID
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID
    WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
        AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
    GROUP BY c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.City, c.Country
    ORDER BY TotalAmountSpent DESC;
END;

