## Expense Tracker

A web-based Expense Tracker system built using **Python (Flask)**, **MySQL**, and **CSS**. This application allows users to manage their daily expenses, set savings goals, and 
view financial summaries in an intuitive interface.

## Features

Add, update, and delete expenses
View total income, total expense, and net balance
Create and monitor savings goals
Transaction history displayed in tabular format
User-friendly authentication and validation
Modular code with DB connection testing
Clean and responsive design using custom CSS

## Tech Stack

- Frontend: HTML/CSS
- Backend: Python (Flask)
- Database: MySQL
- Others: SQL scripts for table creation & testing

## File Structure

ExpenseTracker/
├── app.py                  # Main Flask application
├── test_db_connection.py   # Script to test MySQL DB connection
├── expensetracker.sql      # SQL script to initialize database tables
├── style.css               # Custom CSS for frontend design
└── README.md               # Project overview


##  Getting Started

1. Clone this repository
   bash
   git clone https://github.com/yourusername/ExpenseTracker.git
   cd ExpenseTracker
   

2. Set up the database 
   - Import `expensetracker.sql` into your MySQL server:
     sql
     source expensetracker.sql;

3. Install dependencies(if any Flask modules are used)
   bash
   pip install flask mysql-connector-python

4. Run the app
   bash
   python app.py

5. Access in browser

   http://localhost:5000


## Notes

- Ensure your MySQL server is running.
- Modify the database credentials inside `test_db_connection.py` and `app.py` if needed.
- 
## Acknowledgements

Inspired by real-life budgeting needs and the desire to help users manage finances efficiently.
