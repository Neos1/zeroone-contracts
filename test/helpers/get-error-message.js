const txError = 'Returned error: VM Exception while processing transaction: revert %s -- Reason given: %s.';
const txErrorShort = 'Returned error: VM Exception while processing transaction: revert %s';


module.exports = {
   getErrorMessage(message){
       return txError.replace(/\%s/g, message);
   },

   getShortErrorMessage(message){
        return txErrorShort.replace(/\%s/g, message);
   }  
}