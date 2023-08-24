import oci
from flask import Flask, Response


def create_app():
    app = Flask(__name__)
    config = oci.config.from_file('/home/mike/.oci/config')

    object_storage_client = oci.object_storage.ObjectStorageClient(config)

    @app.route('/get_image')
    def get_image():
        get_object_response = object_storage_client.get_object(
            namespace_name="lr4poue3hwjl",
            bucket_name="ewp_image_store",
            object_name="weddings/Ellie and Pete/cover.jpg")

        image_data = get_object_response.data

        return Response(image_data, content_type='image/jpeg')

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host="0.0.0.0", port=5000)
