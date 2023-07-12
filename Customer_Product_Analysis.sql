--To compute the low stock for each product using a correlated subquery
SELECT productCode,ROUND(SUM(quantityOrdered) * 1.0/ (SELECT quantityInStock
														FROM products p
														WHERE o.productCode = p.productCode), 2) AS low_stock
FROM orderdetails AS o
GROUP BY productCode
ORDER BY low_stock
LIMIT 10;

--to compute the product performance for each product
SELECT productCode, SUM(quantityOrdered * priceEach) as product_performance
   FROM orderdetails
  GROUP BY productCode
  ORDER BY product_performance DESC
LIMIT 10 ;

--Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using the IN operator.
WITH
  lowstock_table AS (
    SELECT
      productCode,
      ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock FROM products p WHERE o.productCode = p.productCode), 2) AS low_stock
    FROM
      orderdetails AS o
    GROUP BY
      productCode
  ),
  productperformance_table AS (
    SELECT
      productCode,
      SUM(quantityOrdered * priceEach) AS product_performance
    FROM
      orderdetails
    GROUP BY
      productCode
  )
SELECT
  low_stock,
  product_performance
FROM
  lowstock_table AS l
JOIN
  productperformance_table AS p ON l.productCode = p.productCode
ORDER BY
  product_performance DESC
LIMIT 5;

--join the products, orders, and orderdetails tables to have customers and products information in the same place
SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) as profit
FROM orders o
JOIN orderdetails od
ON o.orderNumber = od.orderNumber
JOIN products p
ON od.productCode = p.productCode
GROUP BY o.customerNumber;

--find the top five VIP customers
WITH profit_table AS(
SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) as profit
FROM orders o
JOIN orderdetails od
ON o.orderNumber = od.orderNumber
JOIN products p
ON od.productCode = p.productCode
GROUP BY o.customerNumber)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, pt.profit
  FROM customers c
  JOIN profit_table as pt
  ON c.customerNumber = pt.customerNumber
  GROUP BY pt.customerNumber
  ORDER BY pt.profit DESC
  LIMIT 5;

  --find the top five least-engaged customers
  WITH profit_table AS(
SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) as profit
FROM orders o
JOIN orderdetails od
ON o.orderNumber = od.orderNumber
JOIN products p
ON od.productCode = p.productCode
GROUP BY o.customerNumber)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, pt.profit
  FROM customers c
  JOIN profit_table as pt
  ON c.customerNumber = pt.customerNumber
  GROUP BY pt.customerNumber
  ORDER BY pt.profit
  LIMIT 5;

  --compute the average of customer profits using the CTE on the previous screen
WITH profit_table AS(
SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) as profit
FROM orders o
JOIN orderdetails od
ON o.orderNumber = od.orderNumber
JOIN products p
ON od.productCode = p.productCode
GROUP BY o.customerNumber)

SELECT AVG(profit) as ltv
FROM profit_table;
