const express = require('express');
const app = express();
const axios = require('axios');

// Middleware to parse JSON body
app.use(express.json());

// Endpoint to create payment intent
app.post('/create-payment-intent', async (req, res) => {
  const { amount, currency } = req.body;

  // Validate the input data
  if (!amount || !currency || isNaN(amount) || amount <= 0 || currency !== 'PHP') {
    return res.status(400).json({ error: 'Invalid amount or currency' });
  }

  try {
    // Make request to PayMongo API to create a payment intent
    const response = await axios.post('https://api.paymongo.com/v1/payment_intents', {
      data: {
        attributes: {
          amount: amount * 100, // Convert amount to centavos
          currency: currency,   // Currency should be 'PHP'
          payment_method_types: ['gcash'], // GCash as payment method
        },
      },
    }, {
      headers: {
        'Authorization': `Basic ${Buffer.from('sk_test_kc5c7FA3yPbEMXdj2TK8uQ1r').toString('base64')}`,
      },
    });

    // Send PayMongo API response back to the client
    res.status(200).json(response.data);
  }catch (error) {
    if (error.response) {
        // Log PayMongo response error details
        console.error('PayMongo Error:', error.response.data);
        return res.status(500).json({
            error: 'Failed to create payment intent',
            details: error.response.data, // Detailed error from PayMongo API
        });
    } else {
        // Log error message if no response was received
        console.error('Error without response:', error.message);
        return res.status(500).json({
            error: 'Failed to create payment intent',
            details: error.message,
        });
    }
}
});

// Start the server
app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
