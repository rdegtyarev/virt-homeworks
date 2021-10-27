CREATE TABLE orders (
	id serial NOT NULL,
	наименование varchar(255) NULL,
	цена integer null,
	PRIMARY KEY (id)
);

CREATE TABLE clients (
	id serial NOT NULL,
	фамилия varchar NULL,
	"страна проживания" varchar NULL,
	CONSTRAINT заказ FOREIGN KEY (id) REFERENCES orders(id)
);
CREATE INDEX страна_проживания_idx ON clients ("страна проживания");