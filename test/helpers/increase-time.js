module.exports = (web3, increase) => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: '2.0', 
            method: 'evm_increaseTime', 
            params: [increase], 
            id: new Date().getSeconds()
        }, (err) => {
            if (err) return reject(err);
            web3.currentProvider.send({
                jsonrpc: '2.0', 
                method: 'evm_mine', 
                params: [], 
                id: new Date().getSeconds()
            }, (err, response) => {
                if (err) return reject(err);
                return resolve(response);
            });
        })
    })
};
