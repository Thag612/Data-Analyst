-- 32. Hight-Value customers
-- We want to send all of our high-value customers a special VIP gift. We're defining high-value customers as those who've made at least 1 order witha total value (not including the discount) equal to $10,000 or more.
-- We only want to consider orders made in the year 2016.
SELECT
C.CustomerID,
c.CompanyName,
O.OrderID,
TotalOrderAmoun
FROM(
    SELECT 
        SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmoun,
        OrderDetails.OrderID
    From OrderDetails
    Group BY OrderDetails.OrderID
)_tmp_OrderDetails
JOIN Orders O
ON O.OrderID = _tmp_OrderDetails.OrderID
JOIN Customers C
ON C.CustomerID = O.CustomerID
WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-01'
AND TotalOrderAmoun >= 10000
ORDER BY TotalOrderAmoun DESC

-- 33. High-value customers - total orders
-- The manager has changed his mind. Instead of requiring that customers have at least one individual orders totaling $10,000 or more, he wants to define high-value customers as those who have orders totaling $15,000 or more in 2016. 
-- How would you change the answer to the problem above?
SELECT
C.CustomerID,
c.CompanyName,
O.OrderID,
TotalOrderAmoun
FROM(
    SELECT 
        SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmoun,
        OrderDetails.OrderID
    From OrderDetails
    Group BY OrderDetails.OrderID
)_tmp_OrderDetails
JOIN Orders O
ON O.OrderID = _tmp_OrderDetails.OrderID
JOIN Customers C
ON C.CustomerID = O.CustomerID
WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-01'
AND TotalOrderAmoun >= 15000
ORDER BY TotalOrderAmoun DESC

-- 34. High-value customers - with discount
-- Change the above query to use the discount when calculating high-value customers. Order by the total amount which includes the discount.
SELECT
OrderID,
ProductID,
UnitPrice,
Quantity,
Discount,
TotalAmountDis = UnitPrice * Quantity * (1- Discount)
from OrderDetails

-- 35. Month-end orders
-- At the end of the month, salespeople are likely to try much harder to get orders, to meet their month-end quotas. Show all orders made on the last day of the month. Order by EmployeeID and OrderID
SELECT
O.EmployeeID,
O.OrderID,
O.OrderDate
FROM Orders O 
WHERE O.OrderDate = EOMONTH(O.OrderDate)
ORDER BY O.EmployeeID, O.OrderID

-- 36. Orders with many line items
-- The Northwind mobile app developers are testing an app that customers will use to show orders. In order to make sure that even the largest orders will show up correctly on the app, they'd like some samples of orders that have lots of individual line items.
-- Show the 10 orders with the most line items, in order of total line items.
SELECT TOP 10
O.OrderID,
COUNT(OD.Quantity) AS TotalOrderDetails
FROM Orders O
JOIN OrderDetails OD
ON O.OrderID = OD.OrderID
GROUP BY O.OrderID
ORDER BY TotalOrderDetails DESC

-- 37. Orders - random assortment
-- The Northwind mobile app developers would now like to just get a random assortment of orders for beta testing on their app. Show a random set of 2% of all orders. 
SELECT TOP 2 PERCENT Orders.OrderID
FROM Orders
ORDER BY RAND()
-- ORDER BY NEWID() mỗi lần load sẽ ra một bộ khác nhau

-- 38. Orders - accidental double-entry
-- Janet Leverling, one of the salespeople, has come to you with a request. She thinks that she accidentally double-entered a line item on an order, with a different ProductID, but the same quantity. She remembers that the quantity was 60 or more. 
-- Show all the OrderIDs with line items that match this, in order of OrderID.
SELECT
OrderID,
Quantity
FROM OrderDetails
WHERE Quantity >= 60
GROUP BY OrderID, Quantity
HAVING COUNT(OrderID) = 2
ORDER BY Quantity ASC

-- 39. Orders - accidental double-entry details
-- Based on the previous question, we now want to show details of the order, for orders that match the above criteria.
WITH cteTable(OrderID, Quantity)
AS(
    SELECT
    OrderID,
    Quantity
    FROM OrderDetails
    WHERE Quantity > 60
    GROUP BY OrderID, Quantity
    HAVING COUNT(*) > 1 
)
SELECT
OrderID,
Quantity,
ProductID,
UnitPrice,
Discount
FROM OrderDetails
WHERE OrderID IN (SELECT OrderID FROM cteTable)
ORDER BY OrderID, Quantity

-- 40. Orders - accidental double-entry details, derived table
SELECT DISTINCT 
OrderDetails.OrderID
,ProductID
,UnitPrice
,Quantity
,Discount
FROM OrderDetails
JOIN (
SELECT 
OrderID
FROM OrderDetails
WHERE Quantity >= 60
GROUP BY OrderID, Quantity
HAVING Count(*) > 1
) PotentialProblemOrders
ON PotentialProblemOrders.OrderID = OrderDetails.OrderID
ORDER BY OrderID, ProductID

-- 41. Late orders
-- Some customers are complaining about their orders arriving late. Which orders are late?
SELECT
OrderID,
OrderDate,
RequiredDate,
ShippedDate
FROM Orders
WHERE ShippedDate > RequiredDate

-- 42. Late orders - which employees?
-- Some salespeople have more orders arriving late than others. Maybe they're not following up on the order process, and need more training.
-- Which salespeoplehave the most orders arriving late?

SELECT
E.EmployeeID,
E.LastName,
COUNT(E.EmployeeID) AS TotalLateOrders
FROM Orders O
JOIN Employees E
ON O.EmployeeID = E.EmployeeID
WHERE ShippedDate >= RequiredDate
GROUP BY E.EmployeeID, E.LastName
ORDER BY TotalLateOrders DESC

-- 43. Late orders vs. total orders
-- Andrew, the VP of sales, has been doing some more thinking some more about the problem of late orders. He realizes that just looking at the number of orders arriving late for each salesperson isn't a good idea.
-- It needs to be compared against the total number of orders per salesperson. Return results like the following: 
WITH LateOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS LateOrders
    FROM Orders
    WHERE ShippedDate > RequiredDate
    GROUP BY EmployeeID
), AllOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS AllOrders
    FROM Orders
    GROUP BY EmployeeID
)
SELECT
E.EmployeeID,
E.LastName,
A.AllOrders,
L.LateOrders
FROM Employees E
JOIN AllOrders A
ON E.EmployeeID = A.EmployeeID
JOIN LateOrders L
ON E.EmployeeID = L.EmployeeID

-- 44. Late orders vs. total orders - missing employee
-- There's an employee missing in the answer from the problem above. Fix the SQL to show all employees who have taken orders
WITH LateOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS LateOrders
    FROM Orders
    WHERE ShippedDate > RequiredDate
    GROUP BY EmployeeID
), AllOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS AllOrders
    FROM Orders
    GROUP BY EmployeeID
)
SELECT
E.EmployeeID,
E.LastName,
A.AllOrders,
L.LateOrders
FROM Employees E
JOIN AllOrders A
ON E.EmployeeID = A.EmployeeID
JOIN LateOrders L
ON E.EmployeeID = L.EmployeeID

-- 45. Late orders vs. total orders - fix null
-- Continuing on the answer for above query, let's fix the results for row 5 - Buchanan. He should have a 0 instead of a Null in LateOrders.
;WITH LateOrders AS
(
	SELECT 
		EmployeeID,
		COUNT(*) AS LateOrders
	FROM Orders
	WHERE ShippedDate > RequiredDate
	GROUP BY EmployeeID
), AllOrders AS
(
	SELECT 
		EmployeeID,
		COUNT(*) AS TotalOrders
	FROM Orders
	GROUP BY EmployeeID
)
SELECT
	Employees.EmployeeID,
	Employees.LastName,
	AllOrders.TotalOrders,
	ISNULL(LateOrders.LateOrders, 0) AS LateOrders
FROM Employees
JOIN AllOrders
	ON AllOrders.EmployeeID = Employees.EmployeeID
LEFT JOIN LateOrders
	ON LateOrders.EmployeeID = Employees.EmployeeID
ORDER BY Employees.EmployeeID ASC;

-- 46. Late orders vs. total orders - percentage
-- Now we want to get the percentage of late orders over total orders.
WITH LateOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS LateOrders
    FROM Orders
    WHERE ShippedDate > RequiredDate
    GROUP BY EmployeeID
), AllOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS AllOrders
    FROM Orders
    GROUP BY EmployeeID
)
SELECT
E.EmployeeID,
E.LastName,
A.AllOrders,
L.LateOrders,
CAST(L.LateOrders AS decimal(10,2)) / A.AllOrders AS LateOrderss
FROM Employees E
JOIN AllOrders A
ON E.EmployeeID = A.EmployeeID
JOIN LateOrders L
ON E.EmployeeID = L.EmployeeID

-- 47. Late orders vs. total orders - fix decimal
-- So now for the PercentageLateOrders, we get a decimal value like we should. But to make the output easier to read, let's cut the PercentLateOrders off at 2 digits to the right of the decimal point
WITH LateOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS LateOrders
    FROM Orders
    WHERE ShippedDate > RequiredDate
    GROUP BY EmployeeID
), AllOrders AS(
    SELECT
    EmployeeID,
    COUNT(*) AS AllOrders
    FROM Orders
    GROUP BY EmployeeID
)
SELECT
E.EmployeeID,
E.LastName,
A.AllOrders,
L.LateOrders,
CAST(
    CONVERT(DECIMAL(10,4), L.LateOrders) / CONVERT(DECIMAL(10,4), A.AllOrders) 
    AS DECIMAL(10,2)
) AS LateOrderss
FROM Employees E
JOIN AllOrders A
ON E.EmployeeID = A.EmployeeID
JOIN LateOrders L
ON E.EmployeeID = L.EmployeeID

-- 48. Customer grouping
-- Andrew Fuller, the VP of sales at Northwind, would like to do a sales campaign for existing customers. He'd like to categorize customers into groups, based on how much they ordered in 2016. Then, depending on which group the customer is in, he will target the customer with different sales materials.
-- The customer grouping categories are 0 to 1,000, 1,000 to 5,000, 5,000 to 10,000, and over 10,000. A good starting point for this query is the answer from the problem “High-value customers - total orders. We don’t want to show customers who don’t have any orders in 2016. Order the results by CustomerID.
WITH TotalOrders_CTE
AS
(
SELECT
	Orders.CustomerID,
	Customers.CompanyName,
	SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmmount
FROM Customers
JOIN Orders
ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails
ON OrderDetails.OrderID = Orders.OrderID
WHERE YEAR(Orders.OrderDate) = 2016
GROUP BY 
	Orders.CustomerID,
	Customers.CompanyName
)
SELECT 
	TotalOrders_CTE.CustomerID,
	TotalOrders_CTE.CompanyName,
	TotalOrders_CTE.TotalOrderAmmount,
	CustomerGroup = 
	CASE
		WHEN TotalOrders_CTE.TotalOrderAmmount < 1000 THEN 'Low'
		WHEN (TotalOrders_CTE.TotalOrderAmmount > 1000 AND TotalOrders_CTE.TotalOrderAmmount < 5000) THEN 'Medium'
		WHEN (TotalOrders_CTE.TotalOrderAmmount > 5000 AND TotalOrders_CTE.TotalOrderAmmount < 10000) THEN 'High'
		ELSE 'Very High'
	END
FROM TotalOrders_CTE
ORDER BY TotalOrders_CTE.CustomerID

-- 49. Customer grouping - fix null
-- There's a bug with the answer for the previous question. The CustomerGroup value for one of the rows is null. Fix the SQL so that there are no nulls in the CustomerGroup field.
WITH TotalOrders_CTE
AS
(
SELECT
	Orders.CustomerID,
	Customers.CompanyName,
	SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmmount
FROM Customers
JOIN Orders
ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails
ON OrderDetails.OrderID = Orders.OrderID
WHERE YEAR(Orders.OrderDate) = 2016
GROUP BY 
	Orders.CustomerID,
	Customers.CompanyName
)
SELECT 
	TotalOrders_CTE.CustomerID,
	TotalOrders_CTE.CompanyName,
	TotalOrders_CTE.TotalOrderAmmount,
	CustomerGroup = 
	CASE
		WHEN (TotalOrders_CTE.TotalOrderAmmount >= 0 AND TotalOrders_CTE.TotalOrderAmmount < 1000) THEN 'Low'
		WHEN (TotalOrders_CTE.TotalOrderAmmount > 1000 AND TotalOrders_CTE.TotalOrderAmmount < 5000) THEN 'Medium'
		WHEN (TotalOrders_CTE.TotalOrderAmmount > 5000 AND TotalOrders_CTE.TotalOrderAmmount < 10000) THEN 'High'
		ELSE 'Very High'
	END
FROM TotalOrders_CTE
ORDER BY TotalOrders_CTE.CustomerID

-- 50. Customer grouping with percentage
-- Based on the above query, show all the defined CustomerGroups, and the percentage in each. Sort by the total in each group, in descending order.
WITH TotalOrders_CTE AS (
SELECT
	Orders.CustomerID,
	Customers.CompanyName,
	SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrdersAmmount
FROM Customers
JOIN Orders
	ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails
	ON OrderDetails.OrderID = Orders.OrderID
WHERE YEAR(Orders.OrderDate) = 2016
GROUP BY 
	Orders.CustomerID,
	Customers.CompanyName
),
CustomerGroups_CTE AS (
SELECT
	TotalOrders_CTE.CustomerID,
	CustomerGroup = 
	CASE
		WHEN TotalOrders_CTE.TotalOrdersAmmount < 1000 THEN 'Low'
		WHEN (TotalOrders_CTE.TotalOrdersAmmount > 1000 AND TotalOrders_CTE.TotalOrdersAmmount < 5000) THEN 'Medium'
		WHEN (TotalOrders_CTE.TotalOrdersAmmount > 5000 AND TotalOrders_CTE.TotalOrdersAmmount < 10000) THEN 'High'
		ELSE 'Very High'
	END
FROM TotalOrders_CTE
)
SELECT
	CustomerGroups_CTE.CustomerGroup,
	COUNT(*) AS TotalInGroup,
	COUNT(*)*1.0/(SELECT COUNT(*) FROM CustomerGroups_CTE) AS PercentageInGroup
FROM CustomerGroups_CTE
JOIN TotalOrders_CTE
	ON TotalOrders_CTE.CustomerID = CustomerGroups_CTE.CustomerID
GROUP BY CustomerGroups_CTE.CustomerGroup
ORDER BY TotalInGroup DESC;

-- 51. Customer grouping - flexible
-- Andrew, the VP of Sales is still thinking about how best to group customers, and define low, medium, high, and very high value customers. He now wants complete flexibility in grouping the customers, based on the dollar amount they've ordered. He doesn’t want to have to edit SQL in order to change the
-- boundaries of the customer groups. How would you write the SQL? There's a table called CustomerGroupThreshold that you will need to use. Use only orders from 2016.
WITH TotalOrders_CTE AS (
SELECT
	Orders.CustomerID,
	Customers.CompanyName,
	SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmmount
FROM Customers
JOIN Orders
	ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails
	ON OrderDetails.OrderID = Orders.OrderID
WHERE YEAR(Orders.OrderDate) = 2016
GROUP BY 
	Orders.CustomerID,
	Customers.CompanyName
)
SELECT 
	TotalOrders_CTE.CustomerID,
	TotalOrders_CTE.CompanyName,
	TotalOrders_CTE.TotalOrderAmmount,
	CustomerGroupThresholds.CustomerGroupName
FROM TotalOrders_CTE
JOIN CustomerGroupThresholds
	ON TotalOrders_CTE.TotalOrderAmmount BETWEEN CustomerGroupThresholds.RangeBottom AND CustomerGroupThresholds.RangeTop
ORDER BY TotalOrders_CTE.CustomerID

-- 52. Countries with suppliers or customers
-- Some Northwind employees are planning a business trip, and would like to visit as many suppliers and customers as possible. For their planning, they’d like to see a list of all countries where suppliers and/or customers are based.
SELECT Country
FROM Customers
UNION
SELECT Country
FROM Suppliers
GROUP BY Country;

-- 53. Countries with suppliers or customers,version 2
-- The employees going on the business trip don’t want just a raw list of countries, they want more details. We’d like to see output like the below, in the Expected Results.
WITH Customers_CTA AS (
    SELECT DISTINCT Country AS CustomersCountry 
    FROM Customers
), Suppliers_CTA AS (
    SELECT DISTINCT Country AS SuppliersCountry 
    FROM Suppliers
)
SELECT * FROM Customers_CTA
FULL OUTER JOIN Suppliers_CTA
ON Customers_CTA.CustomersCountry = Suppliers_CTA.SuppliersCountry

-- 54. Countries with suppliers or customers - version 3
-- The output of the above is improved, but it’s still not ideal. What we’d really like to see is the country name, the total suppliers, and the total customers.
WITH Customers_CTA AS (
    SELECT Country, COUNT(*) AS TotalCustomers 
    FROM Customers GROUP BY Country
), Suppliers_CTA AS (
    SELECT Country, COUNT(*) AS TotalSuppliers 
    FROM Suppliers GROUP BY Country
)
SELECT
ISNULL(Customers_CTA.Country, Suppliers_CTA.Country) AS Country,
ISNULL(Suppliers_CTA.TotalSuppliers, 0) AS TotalSupplier,
ISNULL(Customers_CTA.TotalCustomers, 0) AS TotalCustomers
FROM Customers_CTA
FULL OUTER JOIN Suppliers_CTA
ON Customers_CTA.Country = Suppliers_CTA.Country
ORDER BY Country ASC

-- 55. First order in each country
-- Looking at the Orders table—we’d like to show details for each order that was the first in that particular country, ordered by OrderID. So, we need one row per ShipCountry, and CustomerID, OrderID, and OrderDate should be of the first order from that country.
WITH Orders_CTE AS (
    SELECT
	ShipCountry,
	CustomerID,
	OrderID,
	CONVERT(varchar, OrderDate, 23) AS OrderDate,
	ROW_NUMBER() OVER(PARTITION BY ShipCountry ORDER BY OrderDate, OrderID ASC) AS RowNumberPerCountry
    FROM Orders
)
SELECT 
	ShipCountry,
	CustomerID,
	OrderID,
	OrderDate
FROM Orders_CTE
WHERE RowNumberPerCountry = 1

-- 56. Customers with multiple orders in 5 day period
-- There are some customers for whom freight is a major expense when ordering from Northwind. However, by batching up their orders, and making one larger order instead of multiple smaller orders in a short period of time, they could reduce their freight costs significantly.
-- Show those customers who have made more than 1 order in a 5 day period. The sales people will use this to help customers reduce their costs.
-- Note: There are more than one way of solving this kind of problem. For this problem, we will not be using Window functions.
SELECT
	InitialOrders.CustomerID,
	InitialOrders.OrderID AS InitialOrderID,
	InitialOrders.OrderDate AS InitialOrderDate,
	NextOrders.OrderID AS NextOrderID,
	NextOrders.OrderDate AS NextOrdersDate,
	DaysBetween = DATEDIFF(day, InitialOrders.OrderDate, NextOrders.OrderDate)
FROM Orders AS InitialOrders
INNER JOIN Orders AS NextOrders
	ON InitialOrders.CustomerID = NextOrders.CustomerID
WHERE 
	InitialOrders.OrderID < NextOrders.OrderID 
	AND DATEDIFF(day, InitialOrders.OrderDate, NextOrders.OrderDate) < 5
ORDER BY 
	InitialOrders.CustomerID, 
	InitialOrderID;

-- 57. Customers with multiple orders in 5 day period, version 2
-- There’s another way of solving the problem above, using Window functions. We would like to see the following results.
WITH Orders_CTE AS(
    SELECT 
	CustomerID, 
	OrderDate = CONVERT(date, OrderDate),
	NextOrderDate = CONVERT(date, LEAD(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY CustomerID, OrderDate))
    FROM Orders
)
SELECT 
    *,
	DaysBetween = DATEDIFF(day, OrderDate, NextOrderDate)
FROM Orders_CTE
WHERE DATEDIFF(day, OrderDate, NextOrderDate) < 5;