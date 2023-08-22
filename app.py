from flask import Flask, jsonify
from flask_restful import Resource, Api, reqparse, abort, marshal, fields
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
api = Api(app)


@app.route('/', method=['GET'])
def hello():
    text = "Hello world!"
    return jsonify({"message": text})


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
