pragma solidity 0.6.1;

contract ERC20 {
  
    uint256 private _totalSupply;
    
    constructor(uint256 totalSupply) public {
      _totalSupply = totalSupply;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
}