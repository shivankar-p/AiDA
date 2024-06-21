const express = require("express");
const productRouter = express.Router();
const auth = require("../middlewares/auth");
const {Product} = require("../model/product");
const Rating = require("../model/rating");

productRouter.get('/api/products', auth ,async (req, res)=>{
    try {

        const products = await Product.find({category : req.query.category});
        res.json(products);
    } catch (error) {
        res.status(500).json({error : e.message});
    }
})

productRouter.post('/api/get-product-by-ids', auth, async (req, res) => {
    console.log('inside api');
    try {
        // Extract the list of IDs from the query parameters
        const {ids} = req.body;
        console.log(ids);
        // Fetch products that match any of the IDs in the list
        const products = await Product.find({ id: { $in: ids } });

        // Send the products as a response
        res.json(products);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
})

productRouter.get('/api/products/search/:name', auth ,async (req, res) => {
    try {
        const products = await Product.find({
            name: {$regex: req.params.name, $options : "i"},
        });
        res.json(products);
    } catch (error) {
        res.status(500).json({error : e.message});
    }
});


productRouter.post("/api/rate-product", auth, async (req, res) => {
    try {
        const { id, rating } = req.body;
        let product = await Product.findById(id);
        for(let i = 0 ; i < product.ratings.length ; i++){
            if(product.ratings[i].userId == req.user){
                product.ratings.splice(i, 1);
                break;
            }
        }

        const ratingSchema = {
            userId : req.user,
            rating,
        }

        product.ratings.push(ratingSchema);
        product = await product.save();

        res.json(product);



    } catch (e) {
        res.status(500).json({error : e.message});
    }
});

productRouter.get("/api/get-product-rating/:id", auth , async (req, res) => {

    try {
        

        const { id } = req.params;
        const product = await Product.findById(id);
        let rating = -1.0;

        for(let i=0; i< product.ratings.length; i++){
            if(product.ratings[i].userId == req.user){
                rating = product.ratings[i].rating;
            } else {
                rating = -1.0;
            }
        }
        
        res.json(rating);

    } catch (e) {
        res.status(500).json({error : e.message});
    }

});


productRouter.get("/api/get-ratings-average/:id", auth, async (req, res)=>{
    try {
        
        const { id } = req.params;
        let product = await Product.findById(id);
        let averageRating = 0;
        let ratingSum = 0;

        for(let i = 0; i<product.ratings.length; i++){
            ratingSum += product.ratings[i].rating;
        }

        averageRating = ratingSum / product.ratings.length;

        if(isNaN(averageRating)){
            averageRating = 0;
        }
     

        res.json(averageRating)


    } catch (e) {
        res.status(500).json({error : e.message});
    }




});


productRouter.get("/api/get-average-ratings-length/:id", auth, async (req, res) => {

    try {
    
        const { id} = req.params;
        const product = await Product.findById(id);
        const averageRatingLength = product.ratings.length;

        res.json(averageRatingLength);

    } catch (e) {
        res.status(500).json({error : e.message});
    }

});



productRouter.get("/api/deal-of-the-day", auth, async (req, res) => {

    try {
        let products = await Product.find({});

        products = products.sort((a, b) => {
            const aTotalRatings = a.ratings.length;
            const bTotalRatings = b.ratings.length;

            return aTotalRatings < bTotalRatings ? 1 : -1;
        });

        res.json(products[0]); 

    } catch (e) {
        res.status(500).json({error : e.message});
    }
})

productRouter.post("/api/add-product-image", auth, async (req, res) => {
    console.log('add product image');
    try {
        const { id, image } = req.body;
        console.log(id, image);
        let product = await Product.findById(id);
        console.log(product);
        if (!product) {
            return res.status(404).json({ error: "Product not found" });
        }

        product.images.push(image);
        product = await product.save();

        console.log('saved');

        res.json(product);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});








module.exports = productRouter;

