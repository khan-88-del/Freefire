import sys
from app import app, db, bcrypt, AdminUser

def make_admin(username, password):
    with app.app_context():
        existing = AdminUser.query.filter_by(username=username).first()
        if existing:
            print(f"User '{username}' pehle se maujood hai!")
            return
        hashed = bcrypt.generate_password_hash(password).decode('utf-8')
        user = AdminUser(username=username, password_hash=hashed)
        db.session.add(user)
        db.session.commit()
        print(f"Super Admin '{username}' kamiyabi se create ho gaya!")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python create_admin.py <username> <password>")
    else:
        make_admin(sys.argv[1], sys.argv[2])
