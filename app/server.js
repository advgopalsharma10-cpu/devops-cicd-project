const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from DevOps CI/CD Project running on Docker and AWS EC2!');
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'devops-node-app'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Application is running on port ${PORT}`);
});
