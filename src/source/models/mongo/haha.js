const mongoose = require('mongoose')
const hahaSchema = new mongoose.Schema({
        email: {
            type: String,
            required: true,
            trim: true
        },
        name: {
            type: String
        },
        phone: {
            type: String
        },
        password_hash: {
            type: String
        },
        avatar: {
            type: String
        },
        birthday: {
            type: Date
        }
})
const Haha = mongoose.model('Haha',hahaSchema)
module.exports = Haha