var mongoose = require('mongoose');
var HistorySchema = mongoose.Schema({
    senderID: { 
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    },

    receiverID: { 
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    },

    fileID : {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'File',
        require: true,
    },

    contentSender: {
        type: String,
        default: '',
    },

    contentReceiver: {
        type: String,
        default: '',
    },

    senderAvatar: {
        type: String,
        default: '',
    },

    descriptionFile: {
        type: String,
        default: '',
    },

    money: {
        type: Number,
        default: 0,
    },

    type: {
        type: Number, // 1: upload, 2: download
        require: true
    },

    date: {
        type: Date,
        default: Date.now
    },

    isSeen: {
        type: Boolean,
        default: false,
    }
});

module.exports = mongoose.model('History', HistorySchema);