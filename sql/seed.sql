-- Entirely fictional fixture. No real athlete, attendance, or financial records.
INSERT INTO reporting_context VALUES (1, '2026-04-30');
INSERT INTO months VALUES ('2026-01-01'),('2026-02-01'),('2026-03-01'),('2026-04-01'),('2026-05-01');
INSERT INTO participants VALUES (1,'P001'),(2,'P002'),(3,'P003'),(4,'P004'),(5,'P005'),(6,'P006'),(7,'P007'),(8,'P008');
INSERT INTO programs VALUES (1,'Weekend Soccer',4),(2,'After-School Multi-Sport',3);
INSERT INTO enrollments VALUES
 (1,1,1,'2026-01-01'),(2,2,1,'2026-01-01'),(3,3,1,'2026-01-01'),
 (4,4,2,'2026-01-01'),(5,5,2,'2026-01-01'),
 (6,1,1,'2026-02-01'),(7,2,1,'2026-02-01'),(8,6,1,'2026-02-01'),
 (9,4,2,'2026-02-01'),(10,1,2,'2026-02-01'),
 (11,1,1,'2026-03-01'),(12,6,1,'2026-03-01'),(13,4,2,'2026-03-01'),(14,7,2,'2026-03-01'),
 (15,6,1,'2026-04-01'),(16,8,1,'2026-04-01'),(17,7,2,'2026-04-01');
INSERT INTO payments VALUES
 (1,1,'2026-01-03','charge','succeeded',7000,NULL),
 (2,2,'2026-01-03','charge','succeeded',7000,NULL),
 (3,3,'2026-01-03','charge','failed',7000,NULL),
 (4,4,'2026-01-04','charge','succeeded',5000,NULL),
 (5,5,'2026-01-04','charge','succeeded',5000,NULL),
 (6,1,'2026-02-02','refund','succeeded',2000,1),
 (7,6,'2026-02-03','charge','succeeded',7000,NULL),
 (8,7,'2026-02-03','charge','succeeded',7000,NULL),
 (9,8,'2026-02-03','charge','succeeded',7000,NULL),
 (10,9,'2026-02-04','charge','succeeded',5000,NULL),
 (11,10,'2026-02-04','charge','succeeded',5000,NULL),
 (12,11,'2026-03-03','charge','succeeded',7000,NULL),
 (13,12,'2026-03-03','charge','succeeded',7000,NULL),
 (14,13,'2026-03-04','charge','succeeded',5000,NULL),
 (15,14,'2026-03-04','charge','succeeded',5000,NULL),
 (16,15,'2026-04-03','charge','succeeded',7000,NULL),
 (17,16,'2026-04-03','charge','failed',7000,NULL),
 (18,16,'2026-04-04','charge','succeeded',7000,NULL),
 (19,17,'2026-04-04','charge','succeeded',5000,NULL);
INSERT INTO sessions VALUES
 (1,1,'2026-01-10','held'),(2,1,'2026-01-17','held'),(3,2,'2026-01-12','held'),
 (4,1,'2026-02-14','held'),(5,2,'2026-02-16','canceled'),
 (6,1,'2026-03-14','held'),(7,2,'2026-03-16','held'),
 (8,1,'2026-04-11','held'),(9,2,'2026-04-13','held');
-- One missing January attendance row intentionally demonstrates conservative denominator handling.
INSERT INTO attendance VALUES
 (1,1,1),(1,2,1),(1,3,0),(2,1,1),(2,2,0),(3,4,1),(3,5,1),
 (4,6,1),(4,7,1),(4,8,1),(6,11,0),(6,12,1),(7,13,1),(7,14,1),
 (8,15,1),(8,16,1),(9,17,1);
