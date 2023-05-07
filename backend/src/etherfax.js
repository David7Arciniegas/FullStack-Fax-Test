// Import the axios library
const axios = require('axios');

// Define the Etherfax class
class Etherfax {

  // The constructor method is called when a new instance of the class is created
  constructor() {
    // Set the base URL for the Etherfax API
    this.baseURL = process.env.API_URL;
    this.apiKey = process.env.API_KEY;
  }

  // The sendFax method sends a fax using the Etherfax API
  async sendFax(dialNumber, faxImage, totalPages, additionalParams = {}) {

    // Combine the fax information with any additional parameters
    const params = {
      DialNumber: dialNumber,
      FaxImage: faxImage,
      TotalPages: totalPages,
      ...additionalParams,
    };

    // Send a POST request to the Etherfax API with the fax information
    const response = await axios.post(`${this.baseURL}/outbox`, params, {
      // Set the headers for the request
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}` // Replace with actual auth token
      },
    });

    // Return the response data from the Etherfax API
    return response.data;
  }
}

// Export the Etherfax class so it can be used by other modules
module.exports = Etherfax;
