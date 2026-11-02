import sys
import os
from app import app, db, bcrypt, AdminUser

def setup_admin(db_url, username, password):
    os.environ['DATABASE_URL'] = db_url
    with app.app_context():
        db.create_all()
        hashed = bcrypt.generate_password_hash(password).decode('utf-8')
        user = AdminUser.query.filter_by(username=username).first()
        if user:
            user.password_hash = hashed
            print(f"[*] Cloud Database: User '{username}' ka password update ho gaya!")
        else:
            new_user = AdminUser(username=username, password_hash=hashed)
            db.session.add(new_user)
            print(f"[+] Cloud Database: Naya Super Admin '{username}' create ho gaya!")
        db.session.commit()

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Usage: python remote_setup_admin.py <DATABASE_URL> <USERNAME> <PASSWORD>")
    else:
        setup_admin(sys.argv[1], sys.argv[2], sys.argv[3])
