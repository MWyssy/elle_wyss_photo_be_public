import os
import re
from flask import Flask, jsonify, Blueprint
from flask_cors import CORS
from natsort import natsorted


def create_app():
    app = Flask(__name__)
    CORS(app, resources={
         r"/api/*": {"origins": "*", "methods": ["GET", "OPTIONS"], "supports_credentials": True}})

    working_directory = os.getcwd()

    @app.route('/', methods=['GET'])
    def hello():
        text = "Hello there!"
        return jsonify({"message": text})

    def generate_endpoint(endpoint, data):
        def dynamic_endpoint():
            return data
        dynamic_endpoint.__name__ = f"{endpoint}"
        app.add_url_rule(endpoint, view_func=dynamic_endpoint)

    def get_weddings(couple):
        files = []
        file_path = f"{working_directory}/cloud/assets/weddings/{couple}"

        for images in os.scandir(file_path):
            if images.is_file():
                files.append(images.path)

        sorted_files = natsorted(files)
        couples = {couple: sorted_files}

        return jsonify({"couple": couples})

    dynamic_routes_bp = Blueprint('dynamic_routes', __name__)

    with app.app_context():
        for index, couple in enumerate(os.scandir(f"{working_directory}/cloud/assets/weddings"), start=1):
            dir_name = re.search('[^/]+$', couple.path).group(0)
            url = '/api/' + dir_name.lower().replace(' ', '-')
            generate_endpoint(url, get_weddings(dir_name))

    app.register_blueprint(dynamic_routes_bp)

    @app.route('/api/portfolio')
    def couples():
        couples = []

        for couple in os.scandir('./cloud/assets/weddings'):
            dir_name = re.search('[^/]+$', couple.path).group(0)
            url = '/' + dir_name.lower().replace(' ', '-')
            cover_image = working_directory + \
                couple.path.replace('.', '') + '/cover.jpg'

            data = {
                "name": dir_name,
                "cover_image": cover_image,
                "url": url
            }
            couples.append(data)

        return jsonify({"couples": couples})

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host="0.0.0.0", port=5000)
