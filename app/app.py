import os
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify(message="Hello from the DevOps", version=os.getenv("APP_VERSION", "dev"))


@app.route("/health")
def health():
    return jsonify(status="ok"), 200


@app.route("/items")
def items():
    return jsonify(items=["alpha", "bravo", "charlie"])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 8080)))
