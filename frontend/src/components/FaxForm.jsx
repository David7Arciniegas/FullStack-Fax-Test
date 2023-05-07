import React, { useState } from "react";
import axios from "axios";
import "./FaxForm.css";
import { Button, Container, TextField, Typography } from "@mui/material";
import svg from "../assets/blob.svg";
import * as pdfjs from 'pdfjs-dist';
pdfjs.GlobalWorkerOptions.workerSrc = `//cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjs.version}/pdf.worker.min.js`;
const FaxForm = () => {
  const [faxNumber, setFaxNumber] = useState(""); // State variable for fax number input
  const [pdfFile, setPdfFile] = useState(null); // State variable for selected PDF file
  const [numPages, setNumPages] = useState("0"); // State variable for counted pages in PDF
  

  const handleFileChange = (event) => {
    // Function to handle file input change
    const file = event.target.files[0];
    if (file) {
      // If file selected
      const reader = new FileReader();
      reader.onload = async (e) => {
        const pdfData = e.target.result;
        setPdfFile(pdfData.split(",")[1]); // Set PDF file to base64 encoded string
        // Count pages in the PDF  
        const loadingTask = pdfjs.getDocument(pdfData); 
        const pdfDocument = await loadingTask.promise;  
        const pageCount = pdfDocument.numPages.toString();  
        setNumPages(pageCount);  
      };
      reader.readAsDataURL(file);
    } else {
      setPdfFile(null); // If no file selected, set PDF file to null
      setNumPages("0"); // If no file selected, set number of pages to 0
    }
  };

  const handleSubmit = async (event) => {
    // Function to handle form submission
    event.preventDefault();
    if (!pdfFile || !faxNumber) {
      // If either fax number or PDF file is missing
      alert("Please complete all the fileds."); // Alert user to fill out all fields
      return;
    }

    const requestBody = {
      // Create request body with fax number and PDF file
      pdfFile: pdfFile,
      faxNumber: faxNumber,
      TotalPages:numPages
    };

    try {
      const response = await axios.post(
        "https://your-api-gateway-url/your-api-endpoint",
        requestBody
      ); // Send POST request to API endpoint
      console.log(response.data);
      alert("Fax enviado exitosamente."); // Alert user that fax was sent successfully
    } catch (error) {
      console.error(error);
      alert(
        "An error occured, please try again"
      ); // Alert user that an error occurred
    }
  };

  return (
    <>

<div className="header-container">
  <h1>Welcome</h1>
  <h5>Here you can send your PDF file to our Fax system</h5>
  
</div>

    <div className="main-container">
      <div className="vector-1"> <img src={svg} alt="Your SVG" /></div>

    
      <Container maxWidth="sm" className="form-container">
        <Typography variant="h4" gutterBottom className="form-title">
         <h4 className="main-container-subtitle">Fax Form</h4> 
        </Typography>
        <form onSubmit={handleSubmit} className="fax-form">
          <TextField
            label="Fax Number"
            value={faxNumber}
            onChange={(event) => setFaxNumber(event.target.value)}
            fullWidth
            required
            margin="normal"
            className="fax-number-input"
          />
          <input
            accept="application/pdf"
            id="pdf-file"
            type="file"
            style={{ display: "none" }}
            onChange={handleFileChange}
          />
          <label htmlFor="pdf-file" className="pdf-file-label">
            <Button
              variant="contained"
              color="primary"
              component="span"
              className="pdf-file-button"
            >
               Upload PDF file
            </Button>
          </label>
          {pdfFile && (
            <Typography variant="subtitle1" className="pdf-file-selected">
              PDF File Selected
            </Typography>
          )}
          <Button
            type="submit"
            variant="contained"
            color="secondary"
            fullWidth
            className="submit-button"
          >
            Send
          </Button>
        </form>
      </Container>
    </div>
    </>
  );
};

export default FaxForm;
