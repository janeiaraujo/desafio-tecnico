import http from 'http';
import PG from 'pg';

const port = Number(process.env.PORT) || 3000;

// Database configuration from environment variables
const dbConfig = {
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'desafio'
};

const client = new PG.Client(dbConfig);

let isConnected = false;

// Initialize database connection
async function connectToDatabase() {
    try {
        await client.connect();
        console.log('Connected to PostgreSQL database');
        isConnected = true;
    } catch (err) {
        console.error('Database connection failed:', err.message);
        isConnected = false;
    }
}

// Initialize database connection on startup
connectToDatabase();

http.createServer(async(req, res) => {
    console.log(`Request: ${req.url}`);

    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.url === "/api") {
        res.setHeader("Content-Type", "application/json");
        res.writeHead(200);

        let result;
        let databaseConnected = isConnected;

        try {
            if (isConnected) {
                const queryResult = await client.query("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
                result = queryResult.rows[0];
            }
        } catch (error) {
            console.error('Database query error:', error.message);
            databaseConnected = false;
        }

        const data = {
            database: databaseConnected,
            userAdmin: result ? .role === "admin" || false
        }

        res.end(JSON.stringify(data));
    } else {
        res.writeHead(404);
        res.end("Not Found");
    }

}).listen(port, '0.0.0.0', () => {
    console.log(`Server is listening on port ${port}`);
});