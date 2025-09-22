from flask import Flask
app = Flask(__name__)

@app.route('/metadata')
def metadata():
    return open("/etc/passwd").read()

@app.route('/env')
def env():
    return open(".env.b64").read()
