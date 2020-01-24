# How to handle ZeroOne calls

To correctly handle ZeroOne calls your contract should inherit from Controlled contract (```./contracts/Controlled/Controlled.sol```) or take it as example.  

Check out ControlledMock (```./contracts/__mocks__/ControlledMock.sol```) for methods, designed to be called by ZeroOne contract.  


Your functions that will be called by ZeroOne contract should correspond to the next abi:
```
{
  "inputs": [
    /** REQUIRED **/
    {
      "components": [
        {
          "internalType": "uint256",
          "name": "ballotId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "questionId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "startBlock",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "endBlock",
          "type": "uint256"
        },
        {
          "internalType": "enum IZeroOne.Result",
          "name": "result",
          "type": "uint8"
        }
      ],
      "internalType": "struct IZeroOne.MetaData",
      "name": "_meta",
      "type": "tuple"
    },
    /** /REQUIRED **/
    /** ...REST
    additional params from question
    /...REST **/
  ],
  "name": "<YourFunctionName>",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
}
```
or web3 example:
```
  web3.eth.abi.encodeParameters(
      ['tuple(uint256,uint256,uint256,uint256,uint256)', ...rest],
      [[0, 0, 0, 0, 0], ...rest]
  )
```
where  
1. ballotId - voting id
2. questionId - question id
3. startBlock - start block number
4. endBlock - end block number
5. result - voting result (undefined, accepted, declined)



If you want more details, you are welcome to look at contracts code (```./contracts/```) and tests (```./test```).

If you have any suggestions to make it better, you are also welcome.