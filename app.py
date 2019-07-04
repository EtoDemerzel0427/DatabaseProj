from flask import Flask, render_template, url_for, flash, redirect
from flask_sqlalchemy import SQLAlchemy
from forms import RegistrationForm, LoginForm

app = Flask(__name__)

app.config['SECRET_KEY'] = '7146c8a2395143ae9f1c9a23a68f6d59'

#Todo:之后tables里应该是根据目前导入了哪些表来决定的，先随便搞搞
tables = [
    {'name': 'tbCell',
     'description': 'The information of each cell',
     'author': 'Weiran Huang',
     'date': 'July 4th, 2019'},
    {'name': 'tbKPI',
     'description': "I don't know what it is either",
     'author': 'Zengrui Wang',
     'date': 'July 3rd, 2019'}
]

@app.route('/')
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        flash(f'Account created for {form.username.data}!', 'success')
        return redirect(url_for('home'))

    return render_template("register.html", title="Register", form=form)

@app.route('/login', methods= ['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        # Todo: 目前就这一个账户
        if form.email.data == 'huangweiran1998@gmail.com' and form.password.data == '12345678':
            flash('You have been logged in!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Login Unsuccessful. Please check your username and password.', 'danger')

    return render_template("login.html", title="Login", form=form)

# a temporary page,
@app.route('/home')
def home():
    return render_template("home.html", title="Home", tables=tables)

@app.route('/upload')
def upload():
    return render_template("upload.html", title="Upload")

@app.route('/download')
def download():
    return render_template("download.html", title="Download")

@app.route('/interference')
def interference():
    return render_template("interference.html", title="Interference")

@app.route('/triples')
def triples():
    return render_template("triples.html", title="Triples")

@app.route('/tbCell')
def tbCell():
    return render_template("tbCell.html", title="tbCell")

@app.route('/eNodeB')
def eNodeB():
    return render_template("eNodeB.html", title="eNodeB")

@app.route('/KPI')
def KPI():
    return render_template("KPI.html", title="KPI")

@app.route('/PRB')
def PRB():
    return render_template("PRB.html", title="PRB")

if __name__ == '__main__':
    app.run()
