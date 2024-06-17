const express = require("express");
const path = require("path");
const mongoose = require("mongoose");
require("dotenv").config({path : path.join(__dirname, '..' , 'config.env')});


const authRouter = require('./routes/auth');
const adminRouter = require('./routes/admin');
const productRouter = require('./routes/product');
const userRouter = require('./routes/user');
const offersRouter = require('./routes/offers');
const app = express();
const PORT = 5001;
const userName = process.env.DB_USERNAME;
const password = encodeURIComponent(process.env.DB_PASSWORD);
const DB = `mongodb://localhost:27017/Amazon`


// middleware
app.use(express.json());
app.use(authRouter);
app.use(adminRouter);
app.use(productRouter);
app.use(userRouter);
app.use(offersRouter);

mongoose.connect(DB).then(()=>{
    console.log('Mongoose Connected!');
}).catch((e)=>{
    console.log(e);
})


app.get("/amazon" , (req, res) => {
    res.send("Welcome to Amazon!");
})

app.listen(PORT, "0.0.0.0",() => {
    console.log(`Connected at PORT : ${PORT}`)
})

module.exports = app;