const mongoose = require('mongoose')

const feedbackSchema = new mongoose.Schema({
    idFile: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref:'File'
    },
    rate:{
        type: Number,
        required: true
    },
    comment:{
        type: String,
        minlength: 25
    }
})

const Feedback = mongoose.model('Feedback', feedbackSchema)
module.exports = Feedback