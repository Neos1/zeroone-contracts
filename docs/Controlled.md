# Controlled
### Controlled

> contract that user contracts should inherit or take as base to corretcly handle ZeroOne calls 

## Constructor
sets zeroOne address

Params:

&nbsp;&nbsp;&nbsp;&nbsp;
1\. **_zeroOne** *of type \`address\`*
\- zeroOne contract address


## Events

### ZeroOneCall((uint256,uint256,uint256,uint256,uint8))
#### 0x9cc1da77a90f7f1319a2ac40e0f37b41731f92d3e46174727621a9c23a57c18a
Params:

&nbsp;&nbsp;&nbsp;&nbsp;
1\. **meta** *of type \`tuple\`*


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1.1\. **ballotId** *of type \`uint256\`*


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1.2\. **questionId** *of type \`uint256\`*


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1.3\. **startBlock** *of type \`uint256\`*


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1.4\. **endBlock** *of type \`uint256\`*


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
1.5\. **result** *of type \`uint8\`*

--- 


[Back to the top ↑](#controlled)