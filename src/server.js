const express = require('express')
const app = express()
const rateLimit = require('express-rate-limit')
const books = require('./books')

// Enable if you're behind a reverse proxy (Heroku, Bluemix, AWS ELB, Nginx, etc)
// see https://expressjs.com/en/guide/behind-proxies.html
// app.set('trust proxy', 1);

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    handler: function (req, res, /*next*/) {
        return res.status(429).json({
            message: 'You sent too many requests. Please wait a while then try again'
        })
    }
});

//  apply to all requests
app.use(limiter)

// Add headers before the routes are defined
app.use(function (req, res, next) {

    // Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', '*')

    // Request methods you wish to allow
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE')

    // Request headers you wish to allow
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type')

    // Set to true if you need the website to include cookies in the requests sent
    // to the API (e.g. in case you use sessions)
    res.setHeader('Access-Control-Allow-Credentials', true)

    // Pass to next layer of middleware
    next()
});

app.get('/', (req, res) => res.send('Hello World!'))

app.get('/books', (req, res) => res.json(books))

app.listen(3000, () => console.log('Server ready'))