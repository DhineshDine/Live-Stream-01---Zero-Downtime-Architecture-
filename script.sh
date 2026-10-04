#!/bin/bash
# 1. Update packages and install Node.js
dnf update -y
dnf install -y nodejs

# 2. Securely fetch the EC2 internal IP using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

# 3. Create the application directory
mkdir -p /var/www/myapp
cd /var/www/myapp

# 4. Generate the Node.js server file
cat << EOF > server.js
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end('<div style="font-family: sans-serif; text-align: center; margin-top: 50px;"><h1>Highly Available Web App</h1><p>Running on EC2 Instance IP: <strong style="color: #FF9900;">' + '$LOCAL_IP' + '</strong></p></div>');
});

server.listen(80, () => {
  console.log('Server is listening on port 80');
});
EOF

# 5. Install PM2 globally and start the app
npm install -g pm2
pm2 start server.js --name "aws-demo-app"
pm2 startup
pm2 save
