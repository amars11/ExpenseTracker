-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS ExpenseTracker;
USE ExpenseTracker;

-- Step 2: Create Tables
CREATE TABLE User (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Phone_Number VARCHAR(15),
    Registration_Date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Category (
    Category_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL,
    Category_Type ENUM('Income', 'Expense') NOT NULL
);

CREATE TABLE Payment_Method (
    Payment_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Payment_Type ENUM('Cash', 'Card', 'Bank Transfer') NOT NULL,
    Account_Details VARCHAR(255),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

-- Adding these tables early to avoid reference issues with procedures
CREATE TABLE Monthly_Expense_Summary (
    Summary_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NOT NULL,
    Total_Expenses DECIMAL(10,2) NOT NULL,
    Summary_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Expense_Report (
    Report_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Report_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Total_Income DECIMAL(10,2),
    Total_Expenses DECIMAL(10,2),
    Budget_Status VARCHAR(50) DEFAULT 'Under Budget',
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Notification (
    Notification_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Message TEXT NOT NULL,
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Read', 'Unread') DEFAULT 'Unread',
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Income_Summary (
    Summary_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NOT NULL,
    Total_Income DECIMAL(10,2) NOT NULL,
    Summary_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Transaction (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Amount DECIMAL(10,2) NOT NULL,
    Transaction_Type ENUM('Income', 'Expense') NOT NULL,
    Category_ID INT,
    Payment_ID INT,
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Description TEXT,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID) ON DELETE SET NULL,
    FOREIGN KEY (Payment_ID) REFERENCES Payment_Method(Payment_ID) ON DELETE SET NULL
);

CREATE TABLE Budget (
    Budget_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Category_ID INT,
    Budget_Amount DECIMAL(10,2) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID) ON DELETE CASCADE
);

CREATE TABLE Savings_Goal (
    Goal_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Goal_Name VARCHAR(100) NOT NULL,
    Target_Amount DECIMAL(10,2) NOT NULL,
    Current_Savings DECIMAL(10,2) DEFAULT 0,
    Target_Date DATE NOT NULL,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Subscription (
    Subscription_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Plan_Name VARCHAR(100) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Status ENUM('Active', 'Inactive') DEFAULT 'Active',
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Vendor (
    Vendor_ID INT AUTO_INCREMENT PRIMARY KEY,
    Vendor_Name VARCHAR(100) NOT NULL,
    Vendor_Type VARCHAR(50),
    Location VARCHAR(255)
);

CREATE TABLE Recurring_Expense (
    Recurring_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Amount DECIMAL(10,2) NOT NULL,
    Category_ID INT,
    Payment_ID INT,
    Frequency ENUM('Daily', 'Weekly', 'Monthly') NOT NULL,
    Next_Due_Date DATE NOT NULL,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID) ON DELETE CASCADE,
    FOREIGN KEY (Payment_ID) REFERENCES Payment_Method(Payment_ID) ON DELETE CASCADE
);

CREATE TABLE Investment (
    Investment_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Investment_Type ENUM('Stocks', 'Mutual Funds', 'Fixed Deposit') NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Investment_Date DATE NOT NULL,
    Investment_Return DECIMAL(10,2),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Loan (
    Loan_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Loan_Type ENUM('Personal', 'Home', 'Education') NOT NULL,
    Loan_Amount DECIMAL(10,2) NOT NULL,
    Loan_Term VARCHAR(50) NOT NULL,
    Status ENUM('Active', 'Paid') DEFAULT 'Active',
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Credit_Card (
    Card_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Card_Number VARCHAR(20) NOT NULL,
    Bank_Name VARCHAR(100) NOT NULL,
    Credit_Limit DECIMAL(10,2) NOT NULL,
    Due_Date DATE NOT NULL,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

CREATE TABLE Feedback (
    Feedback_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

-- Step 3: Insert Sample Data
-- Insert data into User table
INSERT INTO User (Name, Email, Password, Phone_Number) VALUES
('Alice Johnson', 'alice.johnson@example.com', 'password123', '1234567890'),
('Bob Smith', 'bob.smith@example.com', 'password123', '1234567891'),
('Charlie Brown', 'charlie.brown@example.com', 'password123', '1234567892'),
('David Wilson', 'david.wilson@example.com', 'password123', '1234567893'),
('Eva Davis', 'eva.davis@example.com', 'password123', '1234567894'),
('Frank Thomas', 'frank.thomas@example.com', 'password123', '1234567895'),
('Grace Lee', 'grace.lee@example.com', 'password123', '1234567896'),
('Hannah White', 'hannah.white@example.com', 'password123', '1234567897'),
('Ian Harris', 'ian.harris@example.com', 'password123', '1234567898'),
('Jane Martin', 'jane.martin@example.com', 'password123', '1234567899');

-- Insert data into Category table
INSERT INTO Category (Category_Name, Category_Type) VALUES
('Salary', 'Income'),
('Freelance', 'Income'),
('Groceries', 'Expense'),
('Rent', 'Expense'),
('Utilities', 'Expense'),
('Entertainment', 'Expense'),
('Transportation', 'Expense'),
('Healthcare', 'Expense'),
('Dining Out', 'Expense'),
('Education', 'Expense');

-- Insert data into Payment_Method table
INSERT INTO Payment_Method (User_ID, Payment_Type, Account_Details) VALUES
(1, 'Cash', NULL),
(2, 'Card', 'Visa **** 1234'),
(3, 'Bank Transfer', 'Bank of America **** 5678'),
(4, 'Cash', NULL),
(5, 'Card', 'MasterCard **** 2345'),
(6, 'Bank Transfer', 'Chase Bank **** 6789'),
(7, 'Cash', NULL),
(8, 'Card', 'Amex **** 3456'),
(9, 'Bank Transfer', 'Wells Fargo **** 7890'),
(10, 'Cash', NULL);

-- Insert data into Expense_Report table first since it's referenced later
INSERT INTO Expense_Report (User_ID, Total_Income, Total_Expenses, Budget_Status) VALUES
(1, 5000.00, 3000.00, 'Under Budget'),
(2, 1500.00, 1600.00, 'Over Budget'),
(3, 2000.00, 1800.00, 'Under Budget'),
(4, 3000.00, 3100.00, 'Over Budget'),
(5, 2500.00, 2400.00, 'Under Budget'),
(6, 3500.00, 3600.00, 'Over Budget'),
(7, 2800.00, 2700.00, 'Under Budget'),
(8, 4000.00, 4200.00, 'Over Budget'),
(9, 3300.00, 3200.00, 'Under Budget'),
(10, 4500.00, 4400.00, 'Under Budget');

-- Insert data into Transaction table
INSERT INTO Transaction (User_ID, Amount, Transaction_Type, Category_ID, Payment_ID, Description) VALUES
(1, 5000.00, 'Income', 1, 1, 'Monthly salary'),
(2, 1500.00, 'Income', 2, 2, 'Freelance project'),
(3, 200.00, 'Expense', 3, 3, 'Weekly groceries'),
(4, 1200.00, 'Expense', 4, 4, 'Monthly rent'),
(5, 150.00, 'Expense', 5, 5, 'Electricity bill'),
(6, 75.00, 'Expense', 6, 6, 'Movie tickets'),
(7, 50.00, 'Expense', 7, 7, 'Gas refill'),
(8, 300.00, 'Expense', 8, 8, 'Doctor consultation'),
(9, 100.00, 'Expense', 9, 9, 'Dinner at restaurant'),
(10, 500.00, 'Expense', 10, 10, 'Online course fee');

-- Insert data into Budget table
INSERT INTO Budget (User_ID, Category_ID, Budget_Amount, Start_Date, End_Date) VALUES
(1, 3, 800.00, '2025-04-01', '2025-04-30'),
(2, 4, 1500.00, '2025-04-01', '2025-04-30'),
(3, 5, 200.00, '2025-04-01', '2025-04-30'),
(4, 6, 100.00, '2025-04-01', '2025-04-30'),
(5, 7, 150.00, '2025-04-01', '2025-04-30'),
(6, 8, 300.00, '2025-04-01', '2025-04-30'),
(7, 9, 250.00, '2025-04-01', '2025-04-30'),
(8, 10, 400.00, '2025-04-01', '2025-04-30'),
(9, 3, 700.00, '2025-04-01', '2025-04-30'),
(10, 4, 1600.00, '2025-04-01', '2025-04-30');

-- Insert data into Savings_Goal table
INSERT INTO Savings_Goal (User_ID, Goal_Name, Target_Amount, Current_Savings, Target_Date) VALUES
(1, 'Buy Laptop', 1500.00, 200.00, '2025-12-01'),
(2, 'Vacation', 3000.00, 500.00, '2025-11-01'),
(3, 'Emergency Fund', 5000.00, 1000.00, '2026-01-01'),
(4, 'Car', 10000.00, 2500.00, '2026-05-01'),
(5, 'Wedding', 20000.00, 5000.00, '2026-09-01'),
(6, 'Home Renovation', 15000.00, 3000.00, '2025-10-01'),
(7, 'Camera', 1200.00, 300.00, '2025-08-01'),
(8, 'New Phone', 1000.00, 250.00, '2025-07-01'),
(9, 'Investment Fund', 20000.00, 4000.00, '2026-03-01'),
(10, 'Education', 8000.00, 1000.00, '2025-12-31');

-- Insert data into Notification table
INSERT INTO Notification (User_ID, Message) VALUES
(1, 'Your budget is on track this month!'),
(2, 'New transaction added'),
(3, 'You received your salary!'),
(4, 'Your savings goal is 50% complete'),
(5, 'Budget limit reached for Groceries'),
(6, 'Subscription payment due tomorrow'),
(7, 'Reminder: Rent due in 3 days'),
(8, 'You have a new message'),
(9, 'Transaction failed'),
(10, 'Goal achieved: Vacation');

-- Insert data into Subscription table
INSERT INTO Subscription (User_ID, Plan_Name, Start_Date, End_Date) VALUES
(1, 'Basic', '2025-01-01', '2026-01-01'),
(2, 'Premium', '2025-02-01', '2026-02-01'),
(3, 'Basic', '2025-03-01', '2026-03-01'),
(4, 'Premium', '2025-04-01', '2026-04-01'),
(5, 'Basic', '2025-01-15', '2026-01-15'),
(6, 'Premium', '2025-02-15', '2026-02-15'),
(7, 'Basic', '2025-03-15', '2026-03-15'),
(8, 'Premium', '2025-04-15', '2026-04-15'),
(9, 'Basic', '2025-01-20', '2026-01-20'),
(10, 'Premium', '2025-02-20', '2026-02-20');

-- Insert data into Vendor table
INSERT INTO Vendor (Vendor_Name, Vendor_Type, Location) VALUES
('Walmart', 'Retail', 'New York'),
('Amazon', 'E-commerce', 'Online'),
('Apple', 'Electronics', 'California'),
('Netflix', 'Entertainment', 'Online'),
('Starbucks', 'Cafe', 'Seattle'),
('Uber', 'Transport', 'Global'),
('Coursera', 'Education', 'Online'),
('AT&T', 'Telecom', 'Texas'),
('Shell', 'Fuel', 'Global'),
('Best Buy', 'Electronics', 'USA');

-- Insert data into Recurring_Expense table
INSERT INTO Recurring_Expense (User_ID, Amount, Category_ID, Payment_ID, Frequency, Next_Due_Date) VALUES
(1, 100.00, 3, 1, 'Monthly', '2025-04-10'),
(2, 50.00, 5, 2, 'Monthly', '2025-04-11'),
(3, 150.00, 4, 3, 'Monthly', '2025-04-12'),
(4, 200.00, 10, 4, 'Monthly', '2025-04-13'),
(5, 70.00, 6, 5, 'Monthly', '2025-04-14'),
(6, 30.00, 7, 6, 'Monthly', '2025-04-15'),
(7, 90.00, 8, 7, 'Monthly', '2025-04-16'),
(8, 60.00, 9, 8, 'Monthly', '2025-04-17'),
(9, 120.00, 3, 9, 'Monthly', '2025-04-18'),
(10, 80.00, 4, 10, 'Monthly', '2025-04-19');

-- Insert data into Investment table
INSERT INTO Investment (User_ID, Investment_Type, Amount, Investment_Date, Investment_Return) VALUES
(1, 'Stocks', 1000.00, '2025-01-10', 1100.00),
(2, 'Mutual Funds', 2000.00, '2025-01-15', 2200.00),
(3, 'Fixed Deposit', 3000.00, '2025-02-01', 3300.00),
(4, 'Stocks', 1500.00, '2025-02-10', 1600.00),
(5, 'Mutual Funds', 2500.00, '2025-03-01', 2700.00),
(6, 'Fixed Deposit', 3500.00, '2025-03-15', 3800.00),
(7, 'Stocks', 1800.00, '2025-04-01', 1900.00),
(8, 'Mutual Funds', 2200.00, '2025-04-05', 2400.00),
(9, 'Fixed Deposit', 4000.00, '2025-04-07', 4400.00),
(10, 'Stocks', 1600.00, '2025-04-08', 1700.00);

-- Insert data into Loan table
INSERT INTO Loan (User_ID, Loan_Type, Loan_Amount, Loan_Term, Status) VALUES
(1, 'Personal', 5000.00, '2 years', 'Active'),
(2, 'Home', 20000.00, '15 years', 'Active'),
(3, 'Education', 10000.00, '5 years', 'Paid'),
(4, 'Personal', 7000.00, '3 years', 'Active'),
(5, 'Home', 25000.00, '20 years', 'Active'),
(6, 'Education', 15000.00, '10 years', 'Paid'),
(7, 'Personal', 4000.00, '1 year', 'Active'),
(8, 'Home', 30000.00, '25 years', 'Active'),
(9, 'Education', 12000.00, '6 years', 'Paid'),
(10, 'Personal', 8000.00, '4 years', 'Active');

-- Insert data into Credit_Card table
INSERT INTO Credit_Card (User_ID, Card_Number, Bank_Name, Credit_Limit, Due_Date) VALUES
(1, '1111222233334444', 'Chase', 5000.00, '2025-04-25'),
(2, '5555666677778888', 'Bank of America', 6000.00, '2025-04-26'),
(3, '9999000011112222', 'Wells Fargo', 7000.00, '2025-04-27'),
(4, '3333444455556666', 'Citibank', 8000.00, '2025-04-28'),
(5, '7777888899990000', 'Capital One', 9000.00, '2025-04-29'),
(6, '1234123412341234', 'US Bank', 10000.00, '2025-04-30'),
(7, '4321432143214321', 'Barclays', 4000.00, '2025-05-01'),
(8, '8765432187654321', 'HSBC', 3000.00, '2025-05-02'),
(9, '5678567856785678', 'PNC', 2000.00, '2025-05-03'),
(10, '2468246824682468', 'TD Bank', 1000.00, '2025-05-04');

-- Insert data into Feedback table
INSERT INTO Feedback (User_ID, Rating, Comments) VALUES
(1, 5, 'Great app! Very helpful.'),
(2, 4, 'Nice design and easy to use.'),
(3, 3, 'Needs more features.'),
(4, 5, 'Excellent customer support.'),
(5, 2, 'Had some bugs.'),
(6, 4, 'Pretty useful overall.'),
(7, 5, 'Love the analytics section.'),
(8, 3, 'Could use improvements in speed.'),
(9, 4, 'Impressive budget features.'),
(10, 5, 'Highly recommended!');

-- Step 4: Create Views
-- 1. View: Budget vs Actual Expenses per User and Category
CREATE OR REPLACE VIEW Budget_vs_Expenses AS
SELECT 
    u.Name AS User_Name,
    c.Category_Name,
    b.Budget_Amount,
    COALESCE(SUM(t.Amount), 0) AS Actual_Expenses,
    (b.Budget_Amount - COALESCE(SUM(t.Amount), 0)) AS Remaining_Budget
FROM Budget b
JOIN User u ON b.User_ID = u.User_ID
JOIN Category c ON b.Category_ID = c.Category_ID
LEFT JOIN Transaction t 
    ON b.User_ID = t.User_ID AND b.Category_ID = t.Category_ID AND t.Transaction_Type = 'Expense'
GROUP BY u.Name, c.Category_Name, b.Budget_Amount;

-- 2. View: Savings Goal Progress
CREATE OR REPLACE VIEW User_Savings_Goals AS
SELECT 
    u.Name AS User_Name,
    sg.Goal_Name,
    sg.Target_Amount,
    sg.Current_Savings,
    ROUND((sg.Current_Savings / sg.Target_Amount) * 100, 2) AS Progress_Percentage
FROM Savings_Goal sg
JOIN User u ON sg.User_ID = u.User_ID;

-- 3. View: Upcoming Recurring Expenses (Next 30 Days)
CREATE OR REPLACE VIEW Upcoming_Recurring_Expenses AS
SELECT 
    u.Name AS User_Name,
    c.Category_Name,
    r.Amount,
    r.Frequency,
    r.Next_Due_Date
FROM Recurring_Expense r
JOIN User u ON r.User_ID = u.User_ID
JOIN Category c ON r.Category_ID = c.Category_ID
WHERE r.Next_Due_Date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- 4. View: User Income and Expense Summary
CREATE OR REPLACE VIEW Income_Expense_Summary AS
SELECT 
    u.Name AS User_Name,
    SUM(CASE WHEN t.Transaction_Type = 'Income' THEN t.Amount ELSE 0 END) AS Total_Income,
    SUM(CASE WHEN t.Transaction_Type = 'Expense' THEN t.Amount ELSE 0 END) AS Total_Expenses
FROM Transaction t
JOIN User u ON t.User_ID = u.User_ID
GROUP BY u.Name;

-- 5. View: Active Loans with User Info
CREATE OR REPLACE VIEW Active_Loans AS
SELECT 
    u.Name AS User_Name,
    l.Loan_Type,
    l.Loan_Amount,
    l.Loan_Term,
    l.Status
FROM Loan l
JOIN User u ON l.User_ID = u.User_ID
WHERE l.Status = 'Active';

-- 6. Additional view for user savings progress
CREATE OR REPLACE VIEW User_Savings_Progress AS
SELECT
    u.Name AS User_Name,
    sg.Goal_Name,
    sg.Target_Amount,
    sg.Current_Savings,
    ROUND((sg.Current_Savings / sg.Target_Amount) * 100, 2) AS Progress_Percentage
FROM Savings_Goal sg
JOIN User u ON sg.User_ID = u.User_ID;

-- 7. Recent transactions view
CREATE OR REPLACE VIEW Recent_Transactions_View AS
SELECT
    u.Name AS User_Name,
    t.Amount,
    t.Transaction_Type,
    c.Category_Name,
    t.Date
FROM Transaction t
JOIN User u ON t.User_ID = u.User_ID
JOIN Category c ON t.Category_ID = c.Category_ID
ORDER BY t.Date DESC
LIMIT 20;

-- Step 5: Create Procedures and Triggers (with modified DELIMITER syntax)
DELIMITER //

-- Procedure 1: Calculate and Insert Monthly Total Expenses per User
CREATE PROCEDURE calc_monthly_expenses()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE uid INT;
  DECLARE total DECIMAL(10,2);
  DECLARE cur CURSOR FOR
    SELECT User_ID, SUM(Amount)
    FROM Transaction
    WHERE Transaction_Type = 'Expense'
    GROUP BY User_ID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO uid, total;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Use REPLACE to handle existing entries
    REPLACE INTO Monthly_Expense_Summary(User_ID, Total_Expenses)
    VALUES (uid, total);
  END LOOP;
  CLOSE cur;
END//

-- Procedure 2: Update Budget Status for Each User
CREATE PROCEDURE update_all_budget_status()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE uid INT;
  DECLARE exp_total DECIMAL(10,2);
  DECLARE bud_total DECIMAL(10,2);
  DECLARE cur CURSOR FOR SELECT DISTINCT User_ID FROM Budget;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO uid;
    IF done THEN
      LEAVE read_loop;
    END IF;

    SELECT COALESCE(SUM(Amount), 0) INTO exp_total FROM Transaction
    WHERE User_ID = uid AND Transaction_Type = 'Expense';

    SELECT COALESCE(SUM(Budget_Amount), 0) INTO bud_total FROM Budget
    WHERE User_ID = uid;

    UPDATE Expense_Report 
    SET Budget_Status = IF(exp_total > bud_total, 'Over Budget', 'Under Budget') 
    WHERE User_ID = uid;
  END LOOP;
  CLOSE cur;
END//

-- Procedure 3: Generate Notifications for High Expenses
CREATE PROCEDURE notify_high_expenses()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE tid INT;
  DECLARE uid INT;
  DECLARE amt DECIMAL(10,2);
  DECLARE cur CURSOR FOR
    SELECT Transaction_ID, User_ID, Amount
    FROM Transaction
    WHERE Transaction_Type = 'Expense' AND Amount > 1000;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO tid, uid, amt;
    IF done THEN
      LEAVE read_loop;
    END IF;
    INSERT INTO Notification(User_ID, Message)
    VALUES (uid, CONCAT('⚠ High Expense Alert: ', amt));
  END LOOP;
  CLOSE cur;
END//

-- Procedure 4: Reward Top Savers
CREATE PROCEDURE reward_top_savers()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE uid INT;
  DECLARE saving DECIMAL(10,2);
  DECLARE cur CURSOR FOR
    SELECT User_ID, Current_Savings FROM Savings_Goal WHERE Current_Savings > 5000;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO uid, saving;
    IF done THEN
      LEAVE read_loop;
    END IF;
    INSERT INTO Notification(User_ID, Message)
    VALUES (uid, ' You are a top saver! Keep it up!');
  END LOOP;
  CLOSE cur;
END//

-- Procedure 5: Summarize All Users' Income
CREATE PROCEDURE summarize_income()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE uid INT;
  DECLARE total_income DECIMAL(10,2);
  DECLARE cur CURSOR FOR
    SELECT DISTINCT User_ID FROM Transaction;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO uid;
    IF done THEN
      LEAVE read_loop;
    END IF;

    SELECT COALESCE(SUM(Amount), 0) INTO total_income
    FROM Transaction
    WHERE User_ID = uid AND Transaction_Type = 'Income';

    -- Use REPLACE to handle existing entries
    REPLACE INTO Income_Summary(User_ID, Total_Income)
    VALUES (uid, total_income);
  END LOOP;
  CLOSE cur;
END//
DELIMITER;
-- TRIGGERS

-- Trigger 1: After Insert on Transaction - Update Savings Goal
DELIMITER //
CREATE TRIGGER after_transaction_insert
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    -- If new transaction is an Income type, increment relevant savings goal
    IF NEW.Transaction_Type = 'Income' THEN
        -- Update the first savings goal for this user (simplified approach)
        UPDATE Savings_Goal
        SET Current_Savings = Current_Savings + (NEW.Amount * 0.1)  -- Save 10% of income
        WHERE User_ID = NEW.User_ID
        LIMIT 1;
    END IF;
END//
DELIMITER ;

-- Trigger 2: Before Insert on Transaction - Validate Budget
DELIMITER //
CREATE TRIGGER before_transaction_insert
BEFORE INSERT ON Transaction
FOR EACH ROW
BEGIN
    DECLARE budget_remaining DECIMAL(10,2);
    
    -- Only check for expense transactions
    IF NEW.Transaction_Type = 'Expense' THEN
        -- Get remaining budget for this category
        SELECT COALESCE(b.Budget_Amount - SUM(t.Amount), b.Budget_Amount) INTO budget_remaining
        FROM Budget b
        LEFT JOIN Transaction t ON b.User_ID = t.User_ID 
                              AND b.Category_ID = t.Category_ID 
                              AND t.Transaction_Type = 'Expense'
        WHERE b.User_ID = NEW.User_ID 
          AND b.Category_ID = NEW.Category_ID
        GROUP BY b.Budget_Amount;
        
        -- If transaction would exceed budget, create notification
        IF budget_remaining < NEW.Amount THEN
            INSERT INTO Notification(User_ID, Message)
            VALUES (NEW.User_ID, CONCAT('Warning: This expense of $', NEW.Amount, ' exceeds your remaining budget for this category.'));
        END IF;
    END IF;
END//
DELIMITER ;

-- Trigger 3: After Update on Savings_Goal - Check Goal Achievement
DELIMITER //
CREATE TRIGGER after_savings_update
AFTER UPDATE ON Savings_Goal
FOR EACH ROW
BEGIN
    -- If goal has been achieved, create notification
    IF NEW.Current_Savings >= NEW.Target_Amount AND OLD.Current_Savings < OLD.Target_Amount THEN
        INSERT INTO Notification(User_ID, Message)
        VALUES (NEW.User_ID, CONCAT('Congratulations! Your savings goal "', NEW.Goal_Name, '" has been achieved!'));
    END IF;
END//
DELIMITER ;

-- Trigger 4: After Insert on Credit_Card - Check Due Date Proximity
DELIMITER //
CREATE TRIGGER after_credit_card_insert
AFTER INSERT ON Credit_Card
FOR EACH ROW
BEGIN
    -- If due date is within 7 days, create notification
    IF DATEDIFF(NEW.Due_Date, CURDATE()) <= 7 THEN
        INSERT INTO Notification(User_ID, Message)
        VALUES (NEW.User_ID, CONCAT('Reminder: Your credit card payment for ', NEW.Bank_Name, ' is due in ', 
                                  DATEDIFF(NEW.Due_Date, CURDATE()), ' days.'));
    END IF;
END//
DELIMITER ;

-- Trigger 5: After Insert on User - Create Default Categories and Payment Methods
DELIMITER //
CREATE TRIGGER after_user_insert
AFTER INSERT ON User
FOR EACH ROW
BEGIN
    -- Create default payment methods
    INSERT INTO Payment_Method (User_ID, Payment_Type, Account_Details)
    VALUES 
        (NEW.User_ID, 'Cash', NULL),
        (NEW.User_ID, 'Card', 'Default Card');
    
    -- Create welcome notification
    INSERT INTO Notification(User_ID, Message)
    VALUES (NEW.User_ID, CONCAT('Welcome to ExpenseTracker, ', NEW.Name, '! Start tracking your finances today.'));
END//
DELIMITER ;

-- CODE TO DISPLAY VIEWS, PROCEDURES, TRIGGERS, AND CURSORS

-- Display information for all views
SELECT 
    TABLE_SCHEMA AS 'Database',
    TABLE_NAME AS 'View Name',
    VIEW_DEFINITION AS 'View Definition'
FROM 
    INFORMATION_SCHEMA.VIEWS
WHERE 
    TABLE_SCHEMA = 'ExpenseTracker';

-- Display information for all procedures
SELECT 
    ROUTINE_SCHEMA AS 'Database',
    ROUTINE_NAME AS 'Procedure Name',
    ROUTINE_DEFINITION AS 'Procedure Definition'
FROM 
    INFORMATION_SCHEMA.ROUTINES
WHERE 
    ROUTINE_SCHEMA = 'ExpenseTracker' 
    AND ROUTINE_TYPE = 'PROCEDURE';

-- Display information for all triggers
SELECT 
    TRIGGER_SCHEMA AS 'Database',
    TRIGGER_NAME AS 'Trigger Name',
    EVENT_MANIPULATION AS 'Event',
    EVENT_OBJECT_TABLE AS 'Table',
    ACTION_STATEMENT AS 'Action Statement',
    ACTION_TIMING AS 'Timing'
FROM 
    INFORMATION_SCHEMA.TRIGGERS
WHERE 
    TRIGGER_SCHEMA = 'ExpenseTracker';

-- Example of how to call each procedure (for demonstration)
DELIMITER //

DELIMITER //

DELIMITER //

-- Function that demonstrates how to use cursors
CREATE FUNCTION demonstrate_cursor_usage() 
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE user_name VARCHAR(100);
    DECLARE total_expense DECIMAL(10,2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE result VARCHAR(255) DEFAULT '';
    
    -- Define a cursor for getting user expenses
    DECLARE expense_cur CURSOR FOR
        SELECT u.Name, SUM(t.Amount)
        FROM User u
        JOIN Transaction t ON u.User_ID = t.User_ID
        WHERE t.Transaction_Type = 'Expense'
        GROUP BY u.Name
        LIMIT 3;
    
    -- Define handler for when no more rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Open cursor
    OPEN expense_cur;
    
    -- Start reading rows
    read_loop: LOOP
        FETCH expense_cur INTO user_name, total_expense;
        
        -- Exit when no more rows
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Process data (here we just concatenate to result)
        SET result = CONCAT(result, user_name, ': $', total_expense, ' | ');
    END LOOP;
    
    -- Close cursor
    CLOSE expense_cur;
    
    RETURN result;
END//

DELIMITER ;

-- Sample SQL to execute all procedures
CALL calc_monthly_expenses();
CALL update_all_budget_status();
CALL notify_high_expenses();
CALL reward_top_savers();
CALL summarize_income();

-- Sample SQL to test user functions with cursors
SELECT demonstrate_cursor_usage() AS 'Top 3 User Expenses';

-- Sample SQL to view results from views
SELECT * FROM Budget_vs_Expenses LIMIT 10;
SELECT * FROM User_Savings_Goals LIMIT 10;
SELECT * FROM Upcoming_Recurring_Expenses LIMIT 10;
SELECT * FROM Income_Expense_Summary LIMIT 10;
SELECT * FROM Active_Loans LIMIT 10;
SELECT * FROM User_Savings_Progress LIMIT 10;
SELECT * FROM Recent_Transactions_View LIMIT 10;
