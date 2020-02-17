USE `essentialmode`;

CREATE TABLE `burgershot` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`store` varchar(100) NOT NULL,
	`item` varchar(100) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `burgershot` (store, item, price) VALUES
	('burgershot', 'hamburger', 25),
	('burgershot', 'heartstopper', 50),
	('burgershot', 'cocacola', 5),
	('burgershot', 'redbull', 5),
	('burgershot', 'water', 5)
;