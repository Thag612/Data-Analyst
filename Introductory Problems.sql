-- Cau1: We have a table called Shippers. Return all the fields from all the shippers
SELECT* 
FROM Shippers

-- Cau2: In the Categories table, selecting all the fields using this SQL:
-- Select * from Categories
-- ...will return 4 columns. We only want to see two columns, CategoryName and Description.
SELECT
CategoryName,
Description
FROM Categories

-- Cau3: We'd like to see just the FirstName, LastName, and HireDate of all the employees with the Title of SalesRepresentative. Write a SQL statement that returnsonly those employees.
SELECT
FirstName,
LastName,
HireDate
From Employees
WHERE Title = 'Sales Representative'

-- Cau4: Now we'd like to see the same columns as above, but only for those employees that both have the title of Sales Representative, and also are in the United States.
SELECT
FirstName,
LastName,
HireDate
From Employees
WHERE Title = 'Sales Representative' AND Country = 'USA'

-- Cau5: Show all the orders placed by a specific employee. The EmployeeID for this Employee (Steven Buchanan) is 5. 
SELECT
OrderID,
OrderDate
FROM Orders
WHERE EmployeeID = 5

-- Cau6: In the Suppliers table, show the SupplierID, ContactName, and ContactTitle for those Supplierswhose ContactTitle is not Marketing Manager.
SELECT
SupplierID,
ContactName,
ContactTitle
FROM Suppliers
WHERE ContactTitle NOT IN ('Marketing Manager')
-- <> thay NOT IN 

-- Cau7: In the products table, we'd like to see the ProductID and ProductName for those products where the ProductName includes the string "queso".
SELECT
ProductID,
ProductName
FROM Products 
WHERE ProductName Like '%queso%'

-- Cau8: Looking at the Orders table, there's a field calledShipCountry. 
-- Write a query that shows the OrderID,CustomerID, and ShipCountry for the orders where the ShipCountry is either France or Belgium.
SELECT
OrderID,
CustomerID,
ShipCountry
From Orders
Where ShipCountry = 'France' OR ShipCountry = 'Belgium'

-- Cau9: Now, instead of just wanting to return all the orders from France of Belgium, we want to show all the orders from any Latin American country. 
-- But we don't have a list of Latin American countries in a table in the Northwind database. 
-- So, we're going to just use this list of Latin American countries thathappen to be in the Orders table:
-- Brazil
-- Mexico
-- Argentina
-- Venezuela
-- It doesn't make sense to use multiple Or statements anymore, it would get too convoluted. Use the In statement.
SELECT
OrderID,
CustomerID,
ShipCountry
FROM Orders
WHERE ShipCountry IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela')

-- Cau10: For all the employees in the Employees table, show the FirstName, LastName, Title, and BirthDate.
-- Order the results by BirthDate, so we have the oldest employees first.
SELECT
FirstName,
LastName,
Title,
BirthDate
FROM Employees
ORDER BY BirthDate ASC

-- Cau11: In the output of the query above, showing the Employees in order of BirthDate, we see the time of the BirthDate field, which we don't want.
-- Show only the date portion of the BirthDate field.
Select
FirstName,
LastName,
Title,
DateOnlyBirthDate = CONVERT(date,BirthDate )
FROM Employees

-- Cau12:Show the FirstName and LastName columns from the Employees table, and then create a new columncalled FullName, showing FirstName and LastName joined together in one column, with a space in- between.
SELECT
FirstName,
LastName,
FirstName + ' ' + LastName AS FullName
FROM 

-- Cau13: In the OrderDetails table, we have the fields UnitPrice and Quantity. Create a new field, TotalPrice, that multiplies these two together. We'll ignore the Discount field for now.
-- In addition, show the OrderID, ProductID, UnitPrice, and Quantity. Order by OrderID and ProductID.
SELECT 
OrderID,
ProductID,
UnitPrice,
Quantity,
TotalPrice = UnitPrice * Quantity
FROM Orders
ORDER BY OrderID, ProductID

-- Cau14: How many customers do we have in the Customers table? 
-- Show one value only, and don't rely on getting the recordcount at the end of a resultset.
SELECT
TotalCustomer = Count(CustomerID)
FROM Customers

-- Cau15: Show the date of the first order ever made in the Orders table.
SELECT
Firstdate = Min(OrderDate)
FROM Orders

-- Cau16: Show a list of countries where the Northwind company has customers.
SELECT
ShipCountry
FROM Orders
GROUP BY ShipCountry

-- Cau17: Show a list of all the different values in the Customers table for ContactTitles. Also include a count for each ContactTitle.
-- This is similar in concept to the previous question "Countries where there are customers" , except we now want a count for each ContactTitle.
SELECT
ContactTitle,
TotalContactTitle = COUNT(ContactTitle)
FROM Customers
GROUP BY ContactTitle
ORDER BY TotalContactTitle DESC

-- Cau18: We'd like to show, for each product, the associated Supplier. Show the ProductID, ProductName, and the CompanyName of the Supplier. Sort by ProductID. This question will introduce what may be a new concept, the Join clause in SQL.
-- The Join clause is used to join two or more relational database tables together in a logical way. Here's a data model of the relationship between Products and Suppliers.
SELECT
ProductID,
ProductName,
CompanyName AS Supplier
FROM Products  P
JOIN Suppliers S
ON P.SupplierID = S.SupplierID

-- Cau19: We'd like to show a list of the Orders that were made, including the Shipper that was used. Show the OrderID, OrderDate (date only), and CompanyName of the Shipper, and sort by OrderID.
-- In order to not show all the orders (there’s more than 800), show only those rows with an OrderID of less than 10300.
SELECT
OrderID,
DateOnly = CONVERT(date, OrderDate),
CompanyName
FROM Shippers S
JOIN Orders   O 
ON S.ShipperID = O.ShipVia
WHERE OrderID < 10300
ORDER BY OrderID ASC