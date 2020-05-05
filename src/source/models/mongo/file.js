var mongoose = require('mongoose');

var fileSchema = mongoose.Schema({
    idSolidity: {
        type: Number,
        trim: true,
        unique: true,
        required: true
    },

    hash: {
        type: String,
        trim: true,
        required: true
    },

    image: {
        type: String,
        trim: true,
        default: "QmYkHh3Q7sRYWnY4sGo2Q2C3UGPgqdGn8fPcFz4ouLT8KL"
    },
    view: {
        type: Number,
        default: 0,
    },
    name: {
        type: String,
        required: true
    },

    description: {
        type: String,
        required: true,
        minlength: 25
    },

    // artist: {
    //     type: String,
    //     require: true,
    // },

    userUpload: { 
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },

    tags: {
        type: [String],
    },

    contractPermission: {
        type: Boolean,
        default: false,
    },

    date: {
        type: Date,
        // `Date.now()` returns the current unix timestamp as a number
        default: Date.now
    },

    isVerifyCopyright: {
        type: Boolean,
        default: null,
    }
});

fileSchema.virtual('contract',{
    ref:'Contract',
    localField:'_id',
    foreignField:'fileID'
})

fileSchema.pre('save', next => {
    if(this.isNew || this.isModified) {
        this.date_updated = Date(Date.now());
    }
    return next();
});

module.exports = mongoose.model('File', fileSchema);