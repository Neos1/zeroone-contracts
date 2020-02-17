pragma solidity 0.6.1;

import "../lib/Ownable.sol";

/**
  @title CustomToken
  @dev Contract implements custom tokens for ZeroOne 
 */
contract CustomToken is Ownable {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => bool)) private _tokenLocks;

  uint256 private _totalSupply;
  
  string private _name;

  string private _symbol;

  address[] _holders;

  address[] _projects;


  event Transfer(address from, address to, uint256 count);

  event TokenLocked (address project, address user);

  /**
    @dev Contrsuctor of tokens
    @param name name of token
    @param symbol short name of token
    @param totalSupply count of tokens
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


  /**
    @dev returns count of tokens
    @return totalSupply
   */
  function totalSupply() public view returns (uint256) { return _totalSupply; }

  /**
    @dev returns count of tokens
    @return name of token
   */
  function name() public view returns(string memory) { return _name; }

  /**
    @dev returns count of tokens
    @return symbol of token
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
    @dev Sets new administrator in Ownable
    @param _newAdmin address of new administrator
    @return is admin successfully changed 
   */
  function setAdmin(
    address _newAdmin
  ) 
    public
    returns (bool) 
  {
    require(_newAdmin != address(0), "Address must be non-empty");
    require(!isProjectAddress(_newAdmin), "Address used as project");
    transferOwnership(_newAdmin);
    return owner() == _newAdmin;
  }

  /**
    @dev add ballot project to list
    @param _project address of ballot project
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
    return true;
  }

  /**
    @dev Transfers tokens from _sender to _recipient
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
    @dev Set lock status of user tokens in project
    @return status
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
    @dev Set unlock status of user tokens in project
    @return status 
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
  @dev getter for status of user tokens lock in project
  @return isLocked 
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
    @dev Transfer tokens from User to admin;
   */
  function transferFrom(
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
    @dev getting projects list
    @return project list
   */
  function getProjects() 
    public
    view 
    returns(address[] memory) 
  {
    return _projects;
  }

  /**
    @dev check if address using as project
    @return isProject
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
  function sendVote(
    address _project
  )
    public
  {
    require(_project != address(0), "Address must be non-empty");
    require(isProjectAddress(_project), "Address is not in project list");
    _lockTokens(_project, msg.sender);
    // TODO: implement sending descision in project
  }

  /**
    @dev unlocks the tokens of msg.sender
    @param _project address of project
    @return isLocked
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
  
  // TODO:implements this after making Ballot
  // add check for address (address is project ?)
  // Make "returning" tokens from project
}
