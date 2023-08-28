import os
import oci
import re
from flask import Flask, jsonify, Blueprint, Response, json
from flask_cors import CORS
import pandas as pd

# Load the OCI config from the default location
config = {
    "user": os.environ["OCI_USER"],
    "key_file": f"{os.path.dirname(os.path.abspath(__file__))}/.oci/mike@wyss.co.uk_2023-08-23T20 03 55.964Z.pem",
    "fingerprint": os.environ["OCI_FINGERPRINT"],
    "tenancy": os.environ["OCI_TENANCY"],
    "region": os.environ["OCI_REGION"]
}
object_storage_client = oci.object_storage.ObjectStorageClient(config)


def create_app():
    # App creation
    app = Flask(__name__)
    CORS(app, resources={
         r"/api/*": {"origins": "*", "methods": ["GET", "OPTIONS"], "supports_credentials": True}})

    find_directories = []

    list_objects_response = object_storage_client.list_objects(
        "lr4poue3hwjl", "ewp_image_store")
    objects = list_objects_response.data.objects

    for object in objects:
        match = re.search(
            r'\/([^\/]+)\/', object.name)
        if match:
            dir_name = match.group(1)
            find_directories.append(dir_name)

    directories = pd.Series(find_directories).drop_duplicates().tolist()

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

    # Get Couple Folders function
    def get_weddings(couple):
        files = 0

        images = []
        url = f"https://lr4poue3hwjl.objectstorage.uk-london-1.oci.customer-oci.com/n/lr4poue3hwjl/b/ewp_image_store/o/"

        for object in objects:
            object_directory = re.search(
                r'\/([^\/]+)\/', object.name).group(1)
            if object_directory == couple:
                images.append(
                    f"{url}{object.name.replace(' ', '%20').replace('/', '%2f')}")

        couple_data = {couple: images}

        return couple_data

    dynamic_routes_bp = Blueprint('dynamic_routes', __name__)

    # Create endpoints
    with app.app_context():
        for index, couple in enumerate(directories, start=1):
            dir_name = directories[index - 1]
            url = '/api/' + dir_name.lower().replace(' ', '-')
            couple_data = get_weddings(dir_name)
            generate_endpoint(url, couple_data)

    app.register_blueprint(dynamic_routes_bp)

    # Portfolio route
    @app.route('/api/portfolio')
    def couples():
        couples = []

        for couple in directories:
            url = '/' + couple.lower().replace(' ', '-')
            cover_image = f"https://lr4poue3hwjl.objectstorage.uk-london-1.oci.customer-oci.com/n/lr4poue3hwjl/b/ewp_image_store/o/weddings%2F{couple.replace(' ', '%20')}%2Fcover.jpg"

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
