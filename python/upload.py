import os
import requests

def upload_file(url, file_path, field_name="file", extra_data=None):
    """
    Uploads a file to the given server URL using multipart/form-data.

    :param url: The endpoint URL to upload the file.
    :param file_path: Path to the file to be uploaded.
    :param field_name: The form field name for the file (default: 'file').
    :param extra_data: Optional dictionary of additional form fields.
    :return: Response object from the server.
    """
    # Validate file existence
    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")

    # Prepare additional form data
    data = extra_data if isinstance(extra_data, dict) else {}

    try:
        # Open file in binary mode
        with open(file_path, "rb") as f:
            files = {field_name: (os.path.basename(file_path), f)}
            response = requests.post(url, files=files, data=data, timeout=15)

        # Raise HTTPError if status code is 4xx/5xx
        response.raise_for_status()
        return response

    except requests.exceptions.RequestException as e:
        print(f"Error uploading file: {e}")
        return None


if __name__ == "__main__":
    # Example usage
    upload_url = "https://httpbin.org/post"  # Test endpoint
    file_to_upload = "example.txt"  # Replace with your file path

    # Create a sample file for demonstration
    if not os.path.exists(file_to_upload):
        with open(file_to_upload, "w") as f:
            f.write("This is a test file for upload.\n")

    # Upload file with extra form data
    response = upload_file(upload_url, file_to_upload, extra_data={"user": "test_user"})

    if response:
        print("Upload successful!")
        print("Server response JSON:")
        print(response.json())
