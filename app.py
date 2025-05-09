import pymysql
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, session
import re
from datetime import datetime, timedelta

app = Flask(__name__)

# Configure MySQL connection parameters
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '@Nilam291',
    'database': 'ExpenseTracker',
    'port': 3306,
    'cursorclass': pymysql.cursors.DictCursor
}

# Secret key for session
app.secret_key = 'your_secret_key_here'

def get_db_connection():
    return pymysql.connect(**db_config)

@app.route('/dashboard')
def dashboard():
    if 'loggedin' not in session:
        return redirect(url_for('login'))
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT * FROM User WHERE User_ID = %s', (session['id'],))
            user = cursor.fetchone()

            cursor.execute('''
                SELECT 
                    SUM(CASE WHEN Transaction_Type = 'Income' THEN Amount ELSE 0 END) AS total_income,
                    SUM(CASE WHEN Transaction_Type = 'Expense' THEN Amount ELSE 0 END) AS total_expenses
                FROM Transaction
                WHERE User_ID = %s
            ''', (session['id'],))
            summary = cursor.fetchone()

            cursor.execute('''
                SELECT t.*, c.Category_Name 
                FROM Transaction t
                JOIN Category c ON t.Category_ID = c.Category_ID
                WHERE t.User_ID = %s
                ORDER BY t.Date DESC
                LIMIT 5
            ''', (session['id'],))
            recent_transactions = cursor.fetchall()

            cursor.execute('''
                SELECT b.*, c.Category_Name,
                       COALESCE(SUM(t.Amount), 0) AS Actual_Expenses,
                       (b.Budget_Amount - COALESCE(SUM(t.Amount), 0)) AS Remaining
                FROM Budget b
                JOIN Category c ON b.Category_ID = c.Category_ID
                LEFT JOIN Transaction t ON b.User_ID = t.User_ID AND b.Category_ID = t.Category_ID AND t.Transaction_Type = 'Expense'
                WHERE b.User_ID = %s
                GROUP BY b.Budget_ID, c.Category_Name
            ''', (session['id'],))
            budgets = cursor.fetchall()

            budget_status = None
            if budgets:
                total_remaining = sum(budget['Remaining'] for budget in budgets)
                budget_status = f"${total_remaining:.2f} remaining across budgets"

            cursor.execute('SELECT * FROM Notification WHERE User_ID = %s AND Status = "Unread" ORDER BY Date DESC', (session['id'],))
            notifications = cursor.fetchall()

            # Fetch savings goals for dashboard
            cursor.execute('SELECT * FROM Savings_Goal WHERE User_ID = %s', (session['id'],))
            savings_goals = cursor.fetchall()
            for goal in savings_goals:
                goal['progress'] = (goal['Current_Savings'] / goal['Target_Amount']) * 100 if goal['Target_Amount'] > 0 else 0
                goal['Current_Amount'] = goal['Current_Savings']

    finally:
        connection.close()

    return render_template('dashboard.html', user=user, total_income=summary['total_income'], total_expenses=summary['total_expenses'], budget_status=budget_status, notifications=notifications, recent_transactions=recent_transactions, savings_goals=savings_goals)
@app.route('/login', methods=['GET', 'POST'])
def login():
    msg = ''
    if request.method == 'POST' and 'email' in request.form and 'password' in request.form:
        email = request.form['email']
        password = request.form['password']
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute('SELECT * FROM User WHERE Email = %s AND Password = %s', (email, password,))
                account = cursor.fetchone()
        finally:
            connection.close()

        if account:
            session['loggedin'] = True
            session['id'] = account['User_ID']
            session['name'] = account['Name']
            return redirect(url_for('dashboard'))
        else:
            msg = 'Incorrect email/password!'

    return render_template('login.html', msg=msg)

@app.route('/logout')
def logout():
    session.pop('loggedin', None)
    session.pop('id', None)
    session.pop('name', None)
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'name' in request.form and 'email' in request.form and 'password' in request.form:
        name = request.form['name']
        email = request.form['email']
        password = request.form['password']
        phone = request.form.get('phone', '')
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute('SELECT * FROM User WHERE Email = %s', (email,))
                account = cursor.fetchone()

                if account:
                    msg = 'Account already exists!'
                elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
                    msg = 'Invalid email address!'
                elif not name or not password or not email:
                    msg = 'Please fill out the form!'
                else:
                    cursor.execute('INSERT INTO User (Name, Email, Password, Phone_Number) VALUES (%s, %s, %s, %s)', (name, email, password, phone))
                    connection.commit()
                    msg = 'You have successfully registered!'
                    return redirect(url_for('login'))
        finally:
            connection.close()

    return render_template('register.html', msg=msg)

@app.route('/add_transaction', methods=['GET', 'POST'])
def add_transaction():
    if 'loggedin' not in session:
        return redirect(url_for('login'))

    msg = ''
    if request.method == 'POST':
        transaction_type = request.form.get('transaction_type')
        amount = request.form.get('amount')
        category = request.form.get('category')
        custom_category = request.form.get('custom_category')
        payment_method = request.form.get('payment_method')
        description = request.form.get('description')

        if not transaction_type or not amount or not payment_method:
            msg = 'Please fill out all required fields.'
        else:
            try:
                amount = float(amount)
                connection = get_db_connection()
                try:
                    with connection.cursor() as cursor:
                        # Handle custom category
                        if custom_category and custom_category.strip():
                            # Check if category already exists
                            cursor.execute('SELECT Category_ID FROM Category WHERE Category_Name = %s', (custom_category.strip(),))
                            existing_cat = cursor.fetchone()
                            if existing_cat:
                                category_id = existing_cat['Category_ID']
                            else:
                                # Insert new category
                                cursor.execute('INSERT INTO Category (Category_Name, Category_Type) VALUES (%s, %s)', (custom_category.strip(), transaction_type))
                                connection.commit()
                                category_id = cursor.lastrowid
                        else:
                            category_id = category

                        cursor.execute('''
                            INSERT INTO Transaction 
                            (User_ID, Amount, Transaction_Type, Category_ID, Payment_ID, Description) 
                            VALUES (%s, %s, %s, %s, %s, %s)
                        ''', (session['id'], amount, transaction_type, category_id, payment_method, description))
                        connection.commit()
                        flash('Transaction added successfully!')
                        return redirect(url_for('dashboard'))
                finally:
                    connection.close()
            except Exception as e:
                msg = f'Error adding transaction: {str(e)}'

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT * FROM Category')
            categories = cursor.fetchall()

            cursor.execute('SELECT * FROM Payment_Method WHERE User_ID = %s', (session['id'],))
            payment_methods = cursor.fetchall()
    finally:
        connection.close()

    return render_template('add_transaction.html', categories=categories, payment_methods=payment_methods, msg=msg)

@app.route('/transactions')
def transactions():
    if 'loggedin' not in session:
        return redirect(url_for('login'))

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('''
                SELECT t.*, c.Category_Name, p.Payment_Type, p.Account_Details
                FROM Transaction t
                JOIN Category c ON t.Category_ID = c.Category_ID
                JOIN Payment_Method p ON t.Payment_ID = p.Payment_ID
                WHERE t.User_ID = %s
                ORDER BY t.Date DESC
            ''', (session['id'],))
            transactions = cursor.fetchall()
    finally:
        connection.close()

    return render_template('transactions.html', transactions=transactions)

@app.route('/budget', methods=['GET', 'POST'])
def budget():
    if 'loggedin' not in session:
        return redirect(url_for('login'))

    msg = ''
    if request.method == 'POST':
        category = request.form.get('category')
        budget_amount = request.form.get('budget_amount')
        start_date = request.form.get('start_date', None)
        end_date = request.form.get('end_date', None)

        if not category or not budget_amount:
            msg = 'Please fill out all required fields.'
        else:
            try:
                from datetime import date, timedelta
                budget_amount = float(budget_amount)
                if not start_date:
                    start_date = date.today().strftime('%Y-%m-%d')
                if not end_date:
                    end_date = (date.today() + timedelta(days=30)).strftime('%Y-%m-%d')
                connection = get_db_connection()
                try:
                    with connection.cursor() as cursor:
                        cursor.execute('''
                            INSERT INTO Budget 
                            (User_ID, Category_ID, Budget_Amount, Start_Date, End_Date) 
                            VALUES (%s, %s, %s, %s, %s)
                        ''', (session['id'], category, budget_amount, start_date, end_date))
                        connection.commit()
                        flash('Budget added successfully!')
                        return redirect(url_for('budget'))
                finally:
                    connection.close()
            except Exception as e:
                msg = f'Error adding budget: {str(e)}'

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('''
                SELECT b.*, c.Category_Name,
                       COALESCE(SUM(t.Amount), 0) AS Actual_Expenses,
                       (b.Budget_Amount - COALESCE(SUM(t.Amount), 0)) AS Remaining
                FROM Budget b
                JOIN Category c ON b.Category_ID = c.Category_ID
                LEFT JOIN Transaction t ON b.User_ID = t.User_ID AND b.Category_ID = t.Category_ID AND t.Transaction_Type = 'Expense'
                WHERE b.User_ID = %s
                GROUP BY b.Budget_ID, c.Category_Name
            ''', (session['id'],))
            budgets = cursor.fetchall()

            cursor.execute('SELECT * FROM Category WHERE Category_Type = "Expense"')
            categories = cursor.fetchall()
    finally:
        connection.close()

    return render_template('budget.html', budgets=budgets, categories=categories, msg=msg)

@app.route('/savings', methods=['GET', 'POST'])
def savings():
    if 'loggedin' not in session:
        return redirect(url_for('login'))

    msg = ''
    if request.method == 'POST':
        goal_name = request.form.get('goal_name')
        target_amount = request.form.get('target_amount')
        current_savings = request.form.get('current_savings', 0)
        target_date = request.form.get('target_date')

        if not goal_name or not target_amount or not target_date:
            msg = 'Please fill out all required fields.'
        else:
            try:
                target_amount = float(target_amount)
                current_savings = float(current_savings)
                connection = get_db_connection()
                try:
                    with connection.cursor() as cursor:
                        cursor.execute('''
                            INSERT INTO Savings_Goal 
                            (User_ID, Goal_Name, Target_Amount, Current_Savings, Target_Date) 
                            VALUES (%s, %s, %s, %s, %s)
                        ''', (session['id'], goal_name, target_amount, current_savings, target_date))
                        connection.commit()
                        flash('Savings goal added successfully!')
                        return redirect(url_for('savings'))
                finally:
                    connection.close()
            except Exception as e:
                msg = f'Error adding savings goal: {str(e)}'

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT * FROM Savings_Goal WHERE User_ID = %s', (session['id'],))
            goals = cursor.fetchall()

            for goal in goals:
                goal['progress'] = (goal['Current_Savings'] / goal['Target_Amount']) * 100 if goal['Target_Amount'] > 0 else 0
                goal['Current_Amount'] = goal['Current_Savings']
    finally:
        connection.close()

    return render_template('savings.html', savings_goals=goals, msg=msg)

@app.route('/mark_notification_read/<int:notification_id>')
def mark_notification_read(notification_id):
    if 'loggedin' not in session:
        return redirect(url_for('login'))

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('UPDATE Notification SET Status = "Read" WHERE Notification_ID = %s AND User_ID = %s', (notification_id, session['id']))
            connection.commit()
    finally:
        connection.close()

    return redirect(url_for('index'))

@app.route('/')
def root():
    return redirect(url_for('dashboard'))

if __name__ == '__main__':
    app.run(debug=True)