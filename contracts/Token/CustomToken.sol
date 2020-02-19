pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../lib/Ownable.sol";
import "../ZeroOne/IZeroOne.sol";

/**
  @title CustomToken
  @dev Contract implements custom tokens for ZeroOne 
 */
contract CustomToken is IZeroOne, Ownable {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => bool)) private _tokenLocks;

  mapping (address => bool) private _isProjects;

  uint256 private _totalSupply;
  
  string private _name;

  string private _symbol;

  address[] _holders;

  address[] _projects;


  event Transfer(address from, address to, uint256 count);

  event TokenLocked(address project, address user);

  event ZeroOneCall(MetaData meta);

  /**
   * @dev Contrsuctor of tokens
   * @param name name of token
   * @param symbol short name of token
   * @param totalSupply count of tokens
   */
  constructor(
    string memory name, 
    string memory symbol, 
    uint256 totalSupply
  ) public {
    _totalSupply = totalSupply;
    _name = name;
    _symbol = symbol;
    _balances[msg.sender] = totalSupply;
    _holders.push(msg.sender);
  }

  modifier onlyZeroOne(address _caller) {
    require(_isProjects[_caller] = true, "Address not contains in projects");
    _;
  }


  /**
   * @dev returns count of tokens
   * @return totalSupply
   */
  function totalSupply() public view returns (uint256) { return _totalSupply; }

  /**
   * @dev returns count of tokens
   * @return name of token
   */
  function name() public view returns(string memory) { return _name; }

  /**
   * @dev returns count of tokens
   * @return symbol of token
   */
  function symbol() public view returns(string memory) { return _symbol; }


  function balanceOf(
    address _user
  ) 
    public 
    view 
    returns (uint256) 
  {
    return _balances[_user];
  }

  /**
   * @dev add ballot project to list
   * @param _project address of ballot project
   */
  function addToProjects(
    address _project
  ) 
    public
    returns (bool)
  {
    require(_project != address(0), "Address must be non-empty");
    require(!isProjectAddress(_project), "Address already in list");
    _projects.push(_project);
    _isProjects[_project] = true;
    return true;
  }

  /**
   * @dev Transfers tokens from _sender to _recipient
   */
  function _transfer(
    address _sender, 
    address _recipient, 
    uint256 _count
  )
    internal 
  {
    require(_balances[_sender] >= _count, "Value must be less or equal user balance");

    uint256 newSenderBalance = _balances[_sender] - _count;
    uint256 newRecipientBalance = _balances[_recipient] + _count;

    _balances[_sender] = newSenderBalance;
    _balances[_recipient] = newRecipientBalance;

    emit Transfer(_sender, _recipient, _count);
  }

  /**
   * @dev Set lock status of user tokens in project
   * @return status
   */
  function _lockTokens(
    address _project,
    address _user
  )
    internal
    returns (bool status) 
  {
      _tokenLocks[_project][_user] = true;
      emit TokenLocked(_project, _user);

      return _tokenLocks[_project][_user];
  }

  /**
   * @dev Set unlock status of user tokens in project
   * @return status 
  */
  function _unlockTokens(
    address _project,
    address _user
  )
    internal
    returns (bool status) 
  {
      _tokenLocks[_project][_user] = false;
      return !_tokenLocks[_project][_user];
  }

  /**
   * @dev getter for status of user tokens lock in project
   * @return isLocked 
  */
  function isTokenLocked(
    address _project,
    address _user
  )
    public
    view
    returns (bool isLocked)
  {
    require(isProjectAddress(_project), "Address is not in project list");
    return _tokenLocks[_project][_user];
  }

  /**
   * @dev Transfer tokens from {_from} to {_to};
   * @param _from adress of user, which tokens will be sended
   * @param _to address of user, which will be token recipient 
   * @param _count count of {_to} user tokens
   */
  function transferBeetweenUsers(
    address _from,
    address _to,  
    uint256 _count
  ) 
    public
    onlyOwner()
    returns (bool) 
  {
    require(_from != address(0), "Sender address must be not null");
    require(_to != address(0), "Recipient address must be not null");
    require(_balances[_from] >= _count, "Value must be less or equal user balance");
    
    _transfer(_from, _to, _count);
    return true;
  }

  /**
   * @dev getting projects list
   * @return project list
   */
  function getProjects() 
    public
    view 
    returns(address[] memory) 
  {
    return _projects;
  }

  /**
   * @dev check if address using as project
   * @return isProject
   */
  function isProjectAddress(
    address _address
  ) 
    public 
    view 
    returns (bool isProject) 
  {
    require(_address != address(0), "Address must be non-empty");

    isProject = false;

    for (uint i = 0; i < _projects.length; i++) {
      address ballotAddress = _projects[i];
      if (ballotAddress == _address) {
       isProject = true; 
       break;
      } else {
        isProject = false;
      }
    }
  }

  /**
    @dev lock tokens of msg.sender and sending vote to ballot
    @param _project address of ballot project
   */
  function transferFrom(
    address _sender,
    address _project
  )
    public
    onlyZeroOne(msg.sender)
  {
    require(_project != address(0), "Address must be non-empty");
    require(isProjectAddress(_project), "Address is not in project list");
    _lockTokens(_project, _sender);
  }

  /**
   * @dev unlocks the tokens of msg.sender
   * @param _project address of project
   * @return isLocked
  */
  function returnFromVoting(
    address _project
  ) 
    public
    returns(bool isLocked)
  {
     require(isProjectAddress(_project), "Address is not in project list");
     _unlockTokens(_project, msg.sender);
     return !isTokenLocked(_project, msg.sender);
  }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(MetaData memory _meta, address newOwner) public onlyZeroOne(msg.sender) {
        _transferOwnership(newOwner);
        emit ZeroOneCall(_meta);
    }

  
  // TODO:implements this after making Ballot
  // add check for address (address is project ?)
  // Make "returning" tokens from project
}
