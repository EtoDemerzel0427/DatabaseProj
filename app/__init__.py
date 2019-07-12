from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_login import LoginManager
import urllib
import flask_excel as excel


app = Flask(__name__)
excel.init_excel(app)

app.config['SECRET_KEY'] = '7146c8a2395143ae9f1c9a23a68f6d59'

# connect to MS SQL Server
params = urllib.parse.quote_plus('DRIVER={SQL Server};SERVER=HWR-SPECTRE;DATABASE=TD_LTE;Trusted_Connection=yes;')
app.config['SQLALCHEMY_DATABASE_URI'] = "mssql+pyodbc:///?odbc_connect=%s" % params
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message_category = 'info'

with app.app_context():
    db.Model.metadata.reflect(db.engine)


from app import routes

