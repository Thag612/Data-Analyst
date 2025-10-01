-- Cau20:  For this problem, we'd like to see the total number of products in each category.
-- Sort the results by the total number of products, in descending order.
SELECT
CategoryName,
TotalProducts = COUNT(*)
FROM Products   P
JOIN Categories C
ON P.CategoryID = C.CategoryID
GROUP BY CategoryName
ORDER BY COUNT(*) DESC

-- Cau21: In the Customers table, show the total number of customers per Country and City.
SELECT
Country,
City,
TotalCustomers = Count(CustomerID)
FROM Customers
GROUP BY Country, City
ORDER BY Count(CustomerID) DESC 

-- Cau22: What products do we have in our inventory that should be reordered?
-- For now, just use the fields UnitsInStock and ReorderLevel, where UnitsInStock is less than the ReorderLevel, ignoring the fields
-- UnitsOnOrder and Discontinued. Order the results by ProductID.
SELECT
ProductID,
ProductName,
UnitsInStock,
ReorderLevel
FROM Products
WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID DESC

-- Cau23: Now we need to incorporate these fields— UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued—into our calculation.
-- We'll define “products that need reordering” with the following:
-- UnitsInStock plus UnitsOnOrder are less than or equal to ReorderLevel
-- The Discontinued flag is false (0).
SELECT
ProductID,
ProductName,
UnitsInStock,
UnitsOnOrder,
ReorderLevel,
Discontinued
FROM Products
WHERE UnitsInStock + UnitsOnOrder <= ReorderLevel
AND Discontinued = 0

-- Cau24: A salesperson for Northwind is going on a business trip to visit customers, and would like to see a list of all customers, sorted by region, alphabetically.
-- However, he wants the customers with no region (null in the Region field) to be at the end, instead of at the top, where you’d normally find the null values.
-- Within the same region, companies should be sorted by CustomerID.
SELECT
CustomerID,
CompanyName,
Region
FROM Customers
ORDER BY
    CASE 
        WHEN Region IS NULL THEN 1
        ELSE 0
    END,
    region,
    CustomerID

-- Cau25: Some of the countries we ship to have very high freight charges. We'd like to investigate some more shipping options for our customers, to be able to offer them lower freight charges.
-- Return the three ship countries with the highest average freight overall, in descending order by average freight.
SELECT TOP 3
ShipCountry,
avgFreight = AVG(Freight)
FROM Orders
GROUP BY ShipCountry
ORDER BY avgFreight DESC

-- Cau26: We're continuing on the question above on high freight charges. 
-- Now, instead of using all the orders we have, we only want to see orders from the year 2015.
SELECT TOP 3
ShipCountry,
avgFreight = AVG(Freight)
FROM Orders
WHERE OrderDate >= '2015-01-01'
GROUP BY ShipCountry
ORDER BY avgFreight DESC

-- Cau27: Another (incorrect) answer to the problem above is this:
-- Select Top 3
-- ShipCountry
-- ,AverageFreight = avg(freight)
-- From Orders
-- Where
-- OrderDate between '1/1/2015' and '12/31/2015'
-- Group By ShipCountry
-- Order By AverageFreight desc;
-- Notice when you run this, it gives Sweden as the ShipCountry with the third highest freight charges.
-- However, this is wrong - it should be France.
-- What is the OrderID of the order that the (incorrect) answer above is missing?
Select Top 3
ShipCountry
,AverageFreight = avg(freight)
From Orders
Where
OrderDate between '2015/01/01' and '2015/12/31'
Group By ShipCountry
Order By AverageFreight desc;

-- Cau28: We're continuing to work on high freight charges. We now want to get the three ship countries with the highest average freight charges.
-- But instead of filtering for a particular year, we want to use the last 12 months of order data, using as the end date the last OrderDate in Orders.
Select Top 3
ShipCountry
,AverageFreight = avg(freight)
From Orders
Where
OrderDate >= DATEADD(YY, -1, (SELECT MAX(OrderDate) FROM Orders))
Group By ShipCountry
Order By AverageFreight desc;

-- Cau29: We're doing inventory, and need to show information like the below, for all orders. Sort by OrderID and Product ID.
SELECT E.EmployeeID, LastName, O.OrderID, ProductName, Quantity
    FROM Orders O
    JOIN OrderDetails OD
        ON OD.OrderID = O.OrderID 
    JOIN Employees E
        ON E.EmployeeID = O.EmployeeID
    JOIN Products P
        ON P.ProductID = OD.ProductID
    ORDER BY O.OrderID, P.ProductID DESC;

-- Cau30: There are some customers who have never actually placed an order. Show these customers.
-- Cach1
SELECT 
    c.CustomerID,
    NULL AS Orders_CustomerID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;
-- Cach2
Select
Customers_CustomerID = Customers.CustomerID,
Orders_CustomerID = Orders.CustomerID
From Customers
left join Orders
on Orders.CustomerID = Customers.CustomerID
WHERE Orders.CustomerID IS NULL

-- Cau31: One employee (Margaret Peacock, EmployeeID 4) has placed the most orders. However, there are some customers who've never placed an order with her.
-- Show only those customers who have never placed an order with her.
SELECT
C.CustomerID,
O.CustomerID
FROM Customers C
LEFT JOIN Orders O
ON C.CustomerID = O.CustomerID
AND O.EmployeeID = 4
WHERE O.CustomerID IS NULL
