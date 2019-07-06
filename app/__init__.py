from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from app.forms import RegistrationForm, LoginForm
import urllib

app = Flask(__name__)

app.config['SECRET_KEY'] = '7146c8a2395143ae9f1c9a23a68f6d59'

# connect to MS SQL Server
params = urllib.parse.quote_plus('DRIVER={SQL Server};SERVER=HWR-SPECTRE;DATABASE=TD_LTE;Trusted_Connection=yes;')
app.config['SQLALCHEMY_DATABASE_URI'] = "mssql+pyodbc:///?odbc_connect=%s" % params
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True

db = SQLAlchemy(app)


from app import routes



# if __name__ == '__main__':
#     app.run()
