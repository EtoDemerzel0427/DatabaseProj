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



class tbAdjCell(db.Model):
    __tablename__ = 'tbAdjCell'

    def __repr__(self):
        return f'{self.S_SECTOR_ID} '
