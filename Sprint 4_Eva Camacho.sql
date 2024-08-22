

CREATE DATABASE SPRINT_4;



CREATE TABLE companies
	(company_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(50),
    country VARCHAR(20),
    website VARCHAR(50));

SELECT * FROM companies;

SHOW VARIABLES LIKE 'secure_file_priv';

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

LOAD DATA
INFILE 'C:\Program Files\MySQL\MySQL Server 8.0\Uploads\companies.csv'
INTO TABLE companies 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;


CREATE TABLE credit_cards
	(id VARCHAR(15) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin CHAR(4),
    cvv CHAR(3),
    track1 VARCHAR(50),
    track2 VARCHAR(50),
    expiring_date VARCHAR(15));

SELECT * FROM credit_cards;

CREATE TABLE users_ca
	(id INT PRIMARY KEY,
    name VARCHAR(15),
    surname VARCHAR (15),
    phone VARCHAR(15),
    email VARCHAR(50),
    birth_date VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(50));
    
    SELECT * FROM users_ca;
    
  CREATE TABLE users_uk
	(id INT PRIMARY KEY,
    name VARCHAR(15),
    surname VARCHAR (15),
    phone VARCHAR(15),
    email VARCHAR(50),
    birth_date VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(50));
    
SELECT * FROM users_uk;
    
CREATE TABLE users_usa
	(id INT PRIMARY KEY,
    name VARCHAR(15),
    surname VARCHAR (15),
    phone VARCHAR(15),
    email VARCHAR(50),
    birth_date VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(50));
    
SELECT * FROM users_usa;

CREATE TABLE total_users AS
SELECT * FROM users_ca
UNION SELECT * FROM users_uk
UNION SELECT * FROM users_usa;

ALTER TABLE total_users ADD PRIMARY KEY (id);

    
CREATE TABLE transactions
    (id VARCHAR(255) PRIMARY KEY,
	credit_card_id VARCHAR(15),
	business_id VARCHAR(20),
    timestamp VARCHAR(50),
    amount DECIMAL(10,2),
    declined TINYINT(1),
    product_ids VARCHAR(50),
	user_id INT,
	lat FLOAT, 
	longitude FLOAT,
    FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (user_id) REFERENCES total_users(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id));
   
SELECT * FROM transactions;
    
-- EJERCICIO 1 - NIVEL 1 --
SELECT *
FROM total_users
WHERE id IN
	(SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(id) >= 30);

-- EJERCICIO 2 - NIVEL 1 --
SELECT iban, company_name, round(avg(amount),2) AS MediaAmount
FROM credit_cards
JOIN transactions ON credit_cards.id = transactions.credit_card_id
JOIN companies ON transactions.business_id = companies.company_id
WHERE company_name LIKE 'Donec Ltd'
GROUP BY iban, company_name;


ALTER TABLE transactions MODIFY timestamp DATE;

-- EJERCICIO 1 - NIVEL 2 --
CREATE TABLE new_transactions AS
WITH transactions_view AS
	(SELECT *,
	 ROW_NUMBER() OVER (PARTITION BY credit_card_id ORDER BY timestamp DESC) AS num_registro
     FROM transactions)
SELECT *
FROM transactions_view
WHERE num_registro <= 3 AND declined = 0
ORDER BY credit_card_id, num_registro;

-- CUANTAS TARJETAS ÚNICAS ESTÁN ACTIVAS? --
SELECT DISTINCT credit_card_id
FROM new_transactions;





-- CREACIÓN DE LA TABLA DE DIMENSIONES "PRODUCTS" --
CREATE TABLE products 
	(id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price VARCHAR(20),
    colour VARCHAR(20),
    weight DECIMAL(5, 2),
    warehouse_id VARCHAR(20));
    
SELECT * FROM products;

CREATE TABLE by_product AS
SELECT transactions.id AS id_Transaccion, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', numbers.n), ',', -1) AS id_Producto
FROM transactions
JOIN (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) numbers
		ON CHAR_LENGTH(product_ids) - CHAR_LENGTH(REPLACE(product_ids, ',', '')) >= numbers.n - 1
JOIN products ON products.id = SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', numbers.n), ',', -1);


SELECT * FROM by_product;

ALTER TABLE by_product MODIFY id_Producto INT;

ALTER TABLE by_product ADD FOREIGN KEY (id_Producto) REFERENCES products(id);

ALTER TABLE by_product ADD FOREIGN KEY (id_Transaccion) REFERENCES transactions(id);

ALTER TABLE transactions ADD FOREIGN KEY (id) REFERENCES by_product(id_Transaccion);

SELECT id_Producto, product_name AS Producto, COUNT(id_Producto) AS NºVentas
FROM by_product
INNER JOIN products ON products.id = by_product.id_Producto
GROUP BY id_Producto, Producto
ORDER BY NºVentas DESC;




 
   
