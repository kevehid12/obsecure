from flask import Flask, request, redirect
import requests

app = Flask(__name__)

@app.route('/redirect', methods=['POST'])
def redirector():
    data = request.get_json()
    url = data.get('redirect_url')
    if url and "localhost" not in url:
        return redirect(url)
    else:
        return requests.get(url).text

@app.route('/')
def index():
    return "Obscura: Submit your redirect_url via POST to /redirect"
