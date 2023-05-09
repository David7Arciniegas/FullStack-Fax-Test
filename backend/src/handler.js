// Import the Etherfax class from the local module file 'etherfax.js'
const Etherfax = require('./etherfax');

// Create a new instance of the Etherfax class
const etherfax = new Etherfax();

// This is the entry point for the Lambda function
exports.handler = async (event) => {
  // Extract the relevant information from the requestd body
  const requestBody = JSON.parse(event.body);
  const pdfFile = requestBody.FaxImage; // The PDF file to be sent
  const faxNumber = requestBody.DialNumber; // The phone number to send the fax to
  const totalPages = requestBody.TotalPages; // The total number of pages in the fax document

  // Use the Etherfax API to send the fax
  const etherfaxResponse = await etherfax.sendFax(faxNumber, pdfFile, totalPages);

  // Return the response from the Etherfax API as a JSON string
  return{
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin" : "*", // Required for CORS support to work
                "Access-Control-Allow-Credentials" : true // Required for cookies, authorization headers with HTTPS
            },
            "body": JSON.stringify(etherfaxResponse),
            "isBase64Encoded": false
        };
};
