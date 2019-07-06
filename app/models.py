from app import db,app

# load data from SQL Server database
with app.app_context():
    db.Model.metadata.reflect(db.engine)

# ORM mapping
class tbAdjCell(db.Model):
    __tablename__ = 'tbAdjCell'

    def __repr__(self):
        return f'{self.S_SECTOR_ID} '
