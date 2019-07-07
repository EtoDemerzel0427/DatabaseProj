from flask import render_template, url_for, flash, redirect, request
from app.forms import RegistrationForm, LoginForm
from app import app, db, bcrypt
from app.models import User
from flask_login import login_user, current_user, logout_user, login_required

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

@app.route('/', methods=['GET', 'POST'])
@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = RegistrationForm()
    app.logger.info('User registration...')
    if form.validate_on_submit():
        app.logger.info('Registering...: Valid input.')
        hashed_pwd = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        user = User(username=form.username.data, email=form.email.data, password=hashed_pwd)

        db.session.add(user)
        db.session.commit()
        flash('Your account has been created! You are now able to log in!', 'success')
        return redirect(url_for('login'))

    app.logger.info('Not valid input.')
    return render_template("register.html", title="Register", form=form)

@app.route('/login', methods= ['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user is not None and bcrypt.check_password_hash(user.password, form.password.data):
            login_user(user, remember=form.remember.data)
            next_page = request.args.get('next')
            return redirect(next_page) if next_page else redirect(url_for('home'))
        # if form.email.data == 'huangweiran1998@gmail.com' and form.password.data == '12345678':
        #     flash('You have been logged in!', 'success')
        #     return redirect(url_for('home'))
        else:
            flash('Login Unsuccessful. Please check your username and password.', 'danger')

    return render_template("login.html", title="Login", form=form)

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('home'))

@app.route('/account')
@login_required
def account():
    return render_template("account.html", title="Account")

# a temporary page,
@app.route('/home')
@login_required
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