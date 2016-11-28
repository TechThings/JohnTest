from apiclient import discovery
from apiclient.http import MediaFileUpload
from oauth2client.client import SignedJwtAssertionCredentials
import base64
import httplib2
import json
import os
import sys

__author__ = 'Michael Cheah'

# OAuth 2.0 scope that will be authorized.
OAUTH2_SCOPE = 'https://www.googleapis.com/auth/drive.file'

# ENV Variable that contains the credentials
CREDENTIALS_ENV_KEY = "GOOGLE_SERVICE_ACCOUNT_CREDENTIAL"

# Metadata about the file.
ANDROID_MIMETYPE = 'application/vnd.android.package-archive'
IOS_MIMETYPE = 'application/octet-stream'
ANDROID_COMSUMER_FOLDER_ID = '0B9b9ZxnCeqg9VEpVdTQtZUF0ZlE'
IOS_CONSUMER_FOLDER_ID = '0B9b9ZxnCeqg9TTRnemkzbVVTM1k'

# Script Mode
MODE_ANDROID = 'android'
MODE_IOS = 'ios'
CURRENT_MODE = MODE_IOS

def collect_artifacts():
    artifacts_dir = os.getenv("BITRISE_DEPLOY_DIR")
    artifacts = []
    for file_to_upload in os.listdir(artifacts_dir):
        if CURRENT_MODE is MODE_ANDROID:
            if file_to_upload.endswith(".apk"):
                artifacts.append(os.path.join(artifacts_dir, file_to_upload))
        elif CURRENT_MODE is MODE_IOS:
            if file_to_upload.endswith(".ipa") or file_to_upload.endswith(".dSYM.zip"):
                artifacts.append(os.path.join(artifacts_dir, file_to_upload))
    return artifacts


def upload_to_gdrive(files):
    if files:
        json_key = json.loads(load_credentials())

        credentials = SignedJwtAssertionCredentials(json_key['client_email'], json_key['private_key'].encode(),
                                                    OAUTH2_SCOPE)

        http = httplib2.Http()
        credentials.authorize(http)

        '''Create Authenticated Drive Service'''
        drive_service = discovery.build('drive', 'v2', http=http)

        '''Configure Android or iOS Mode'''
        mimetype = None
        upload_folder_id = None
        
        if CURRENT_MODE is MODE_ANDROID:
            mimetype = ANDROID_MIMETYPE
            upload_folder_id = ANDROID_COMSUMER_FOLDER_ID
        elif CURRENT_MODE is MODE_IOS:
            mimetype = IOS_MIMETYPE
            upload_folder_id = IOS_CONSUMER_FOLDER_ID
        else:
            print "\nError! Invalid Mode"
            return

        for file_to_upload in files:
            print("Uploading: " + file_to_upload);
            filename = os.path.basename(os.path.normpath(file_to_upload))
            media_body = MediaFileUpload(
                file_to_upload,
                mimetype=mimetype,
                resumable=True
            )
            '''The body contains the metadata for the file'''
            body = {
                'title': filename,
                'parents': [{'id': upload_folder_id}]
            }

            '''Perform the request and print the result'''
            request = drive_service.files().insert(body=body, media_body=media_body)
            response = None
            while response is None:
                status, response = request.next_chunk()
                if status:
                    sys.stdout.write("%d%%..." % int(status.progress() * 100))
            print "\nUpload Complete!"


def load_credentials():
    encoded_credential = os.getenv(CREDENTIALS_ENV_KEY)
    if encoded_credential:
        return base64.decodestring(encoded_credential)
    return None


def main():
    files_to_upload = collect_artifacts()
    if files_to_upload:
        '''Upload to Google Drive'''
        upload_to_gdrive(files_to_upload)


if __name__ == "__main__":
    main()
