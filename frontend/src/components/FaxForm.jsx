import React, { useState } from "react";
import "./FaxForm.css";
import { Button, Container, TextField, Typography } from "@mui/material";

const FaxForm = () => {
  const [faxNumber, setFaxNumber] = useState(""); // State variable for fax number input
  const [pdfFile, setPdfFile] = useState(null); // State variable for selected PDF file

  const handleFileChange = (event) => {
    // Function to handle file input change
    const file = event.target.files[0];
    if (file) {
      // If file selected
      const reader = new FileReader();
      reader.onload = (e) => {
        setPdfFile(e.target.result.split(",")[1]); // Set PDF file to base64 encoded string
      };
      reader.readAsDataURL(file);
    } else {
      setPdfFile(null); // If no file selected, set PDF file to null
    }
  };

  const handleSubmit = async (event) => {
    // Function to handle form submission
    event.preventDefault();
    if (!pdfFile || !faxNumber) {
      // If either fax number or PDF file is missing
      alert("Por favor, complete todos los campos."); // Alert user to fill out all fields
      return;
    }

    const requestBody = {
      // Create request body with fax number and PDF file
      pdfFile: pdfFile,
      faxNumber: faxNumber,
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
        "Ocurrió un error al enviar el fax. Por favor, inténtelo de nuevo."
      ); // Alert user that an error occurred
    }
  };

  return (
    <div className="main-container">
      <Container maxWidth="sm" className="form-container">
        <Typography variant="h4" gutterBottom className="form-title">
          Fax Form
        </Typography>
        <form onSubmit={handleSubmit} className="fax-form">
          <TextField
            label="Número de fax"
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
              Subir Archivo .PDF
            </Button>
          </label>
          {pdfFile && (
            <Typography variant="subtitle1" className="pdf-file-selected">
              Archivo PDF seleccionado
            </Typography>
          )}
          <Button
            type="submit"
            variant="contained"
            color="secondary"
            fullWidth
            className="submit-button"
          >
            Enviar
          </Button>
        </form>
      </Container>
    </div>
  );
};

export default FaxForm;
