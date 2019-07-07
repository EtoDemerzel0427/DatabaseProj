from app import app
import logging
from logging.handlers import RotatingFileHandler

if __name__ == '__main__':
    # set logging
    handler = RotatingFileHandler('app.log', maxBytes=10000, backupCount=1)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)
    app.run(debug=True)