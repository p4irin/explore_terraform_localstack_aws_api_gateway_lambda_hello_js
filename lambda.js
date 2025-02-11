'use strict'

const apiHandler = (payload, context, callback) => {

    callback(null, {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from Lambda',
            // payload: payload,
            // context: context
        }),
    }); 
}
    
module.exports = {
    apiHandler,
}
