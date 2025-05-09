import pymysql

try:
    connection = pymysql.connect(host='localhost',
                                 user='root',
                                 password='@Nilam291',
                                 database='ExpenseTracker',
                                 port=3306)
    with connection.cursor() as cursor:
        cursor.execute('SELECT 1')
        result = cursor.fetchone()
        print("Connection successful, query result:", result)
    connection.close()
except Exception as e:
    print("Connection failed:", e)
