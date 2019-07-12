from app import db, login_manager
from flask_login import UserMixin

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# ORM mapping

class User(db.Model, UserMixin):
    __tablename__= 'tbUser'

    def __repr__(self):
        return f"User('{self.username}', '{self.email}')"

class tbCell_export(db.Model):
    __tablename__ = 'tbCell_export'

class tbKPI(db.Model):
    __tablename__ = 'tbKPI'

class tbPRB(db.Model):
    __tablename__ = 'tbPRB'

class Cell(db.Model):
    __tablename__ = 'tbCell'

    def __repr__(self):
        return f'{self.S_SECTOR_ID} '

class tbKPI_export(db.Model):
    __tablename__ = 'tbKPI_export'

class tbPRB_export(db.Model):
    __tablename__ = 'tbPRB_export'

class tbC2INew(db.Model):
    __tablename__ = 'tbC2INew'

class tbC2I3(db.Model):
    __tablename__ = 'tbC2I3'