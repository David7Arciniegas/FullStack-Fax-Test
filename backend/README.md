# NodeJS Backend using Etherfax API.
  
This is a NodeJS backend project that uses the Etherfax API to send faxes. It includes the following files and folders:  
  
- `package-lock.json`: auto-generated file that locks the version of each installed package.  
- `package.json`: file that lists the project dependencies and other metadata.  
- `README.md`: this file.  
- `tree.txt`: file that shows the folder structure of the project.  
- `src`: folder that contains the source code of the project.  
  - `etherfax.js`: file that defines the `Etherfax` class, which provides a wrapper around the Etherfax API.  
  - `handler.js`: file that defines the `handler` function, which is the entry point for the Lambda function that sends the faxes.  
  
## Usage  
  
To use this project, you need to have a valid Etherfax API token. Replace the placeholder value in the `Authorization` header of the `axios.post` call in `etherfax.js` with your actual token.  
  
Then, you can deploy the project to your preferred serverless platform, such as AWS Lambda or Google Cloud Functions. Make sure to set the correct environment variables and permissions for the function to work properly.  
  
To send a fax, you can make a POST request to the URL of the deployed function, with the following JSON payload:  
  
```json  
{  
  "DialNumber": "+1234567890",  
  "FaxImage": "base64-encoded-pdf-file",  
  "TotalPages": 10  
}  

Replace the values with the phone number you want to send the fax to, the base64-encoded PDF file, and the total number of pages in the document.

The function will return a JSON response with the status code and message from the Etherfax API.

```

# License
This project is licensed under the MIT License. See the LICENSE file for details.  
