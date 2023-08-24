import os
import oci
import re
from flask import Flask, jsonify, Blueprint, Response
from flask_cors import CORS


def create_app():
    # App creation
    app = Flask(__name__)
    CORS(app, resources={
         r"/api/*": {"origins": "*", "methods": ["GET", "OPTIONS"], "supports_credentials": True}})

    working_directory = os.getcwd()

    # Root route
    @app.route('/', methods=['GET'])
    def hello():
        text = "Hello there!"
        return jsonify({"message": text})

    # Generate Endpoint function
    def generate_endpoint(endpoint, data):
        def dynamic_endpoint():
            return data
        dynamic_endpoint.__name__ = f"{endpoint}"
        app.add_url_rule(endpoint, view_func=dynamic_endpoint)

    # Get images from OCI bucket

    def get_image(couple, image):
        couple_endpoint = couple.replace(' ', '%20')
        url = "https://objectstorage.uk-london-1.oraclecloud.com/n/lr4poue3hwjl/b/ewp_image_store/o/weddings%2F"

        return f"{url}{couple_endpoint}%2f{image}.jpg"

    # Get Couple Folders function
    def get_weddings(couple):
        files = 0
        file_path = f"{working_directory}/assets/weddings/{couple}"
        images = []
        url = f"https://objectstorage.uk-london-1.oraclecloud.com/n/lr4poue3hwjl/b/ewp_image_store/o/weddings%2F{couple.replace(' ', '%20')}%2F"

        for image in os.scandir(file_path):
            if image.is_file():
                files += 1

        for x in range(files - 1):
            images.append(f"{url}{x + 1}.jpg")

        couple_data = {couple: images}

        return couple_data

    dynamic_routes_bp = Blueprint('dynamic_routes', __name__)

    # Create endpoints
    with app.app_context():
        for index, couple in enumerate(os.scandir(f"{working_directory}/assets/weddings"), start=1):
            dir_name = re.search('[^/]+$', couple.path).group(0)
            url = '/api/' + dir_name.lower().replace(' ', '-')
            couple_data = get_weddings(dir_name)
            generate_endpoint(url, couple_data)

    app.register_blueprint(dynamic_routes_bp)

    # Portfolio route
    @app.route('/api/portfolio')
    def couples():
        couples = []

        for couple in os.scandir('./assets/weddings'):
            couple = re.search('[^/]+$', couple.path).group(0)
            url = '/' + couple.lower().replace(' ', '-')
            cover_image = f"https://objectstorage.uk-london-1.oraclecloud.com/n/lr4poue3hwjl/b/ewp_image_store/o/weddings%2F{couple.replace(' ', '%20')}%2Fcover.jpg"

            data = {
                "name": couple,
                "cover_image": cover_image,
                "url": url
            }
            couples.append(data)

        return jsonify({"couples": couples})

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host="0.0.0.0", port=5000)
