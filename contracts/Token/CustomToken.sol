pragma solidity 0.6.1;

import "../lib/Ownable.sol";


/**
  @title CustomToken
  @dev Contract implements custom tokens for ZeroOne 
 */
contract CustomToken is Ownable {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _ballotBalances;

  uint256 private _totalSupply;
  
  string private _name;

  string private _symbol;

  address[] _holders;

  address[] _projects;


  event Transfer(address from, address to, uint256 count);

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
    @dev Transfers tokens from _sender to _recipient
   */
  function _transfer(
    address _sender, 
    address _recipient, 
    uint256 _count
  )
    public 
  {
    require(_balances[_sender] >= _count, "Value must be less or equal user balance");

    uint256 newSenderBalance = _balances[_sender] - _count;
    uint256 newRecipientBalance = _balances[_recipient] + _count;

    _balances[_sender] = newSenderBalance;
    _balances[_recipient] = newRecipientBalance;

    emit Transfer(_sender, _recipient, _count);
  }

  /**
    @dev Sets user token balances for projects
   */
  function _setBallotBalance(
    address _user,
    uint256 _amount
  )
    internal 
  {
    for (uint i = 0; i < _projects.length; i++) {
      address ballotAddress = _projects[i];
      _ballotBalances[ballotAddress][_user] = _amount;
    }
  }


  /**
    @dev Transfer tokens from User to admin;
   */
  function _transferToAdmin(
    address _from,  
    uint256 _count
  ) 
    public
    onlyOwner()
    returns (bool) 
  {
    address _owner = owner();
    require(_from != address(0), "Address must be not null");
    require(_balances[_from] >= _count, "Value must be less or equal user balance");

    _transfer(_from, _owner, _count);
    _setBallotBalance(_from, _balances[_from]);
    _setBallotBalance(_owner, _balances[_owner]);

    return true;
  }

  /**
    @dev Tranfer tokens from admin to User
   */
  function _transferToUser(
    address _to,  
    uint256 _count
  ) 
    public
    onlyOwner() 
    returns (bool)
  {
    address _owner = owner();
    require(_to != address(0), "Address must be not null");
    require(_balances[_owner] >= _count, "Value must be less or equal admin balance");

    _transfer(_owner, _to, _count);
    _setBallotBalance(_to, _balances[_to] );
    _setBallotBalance(_owner, _balances[_owner] );

    return true;
  }


  function addToProjects(
    address _project
  ) 
    public
    returns (bool)
  {
    // TODO
    // add check for address (address is project ?)
    require(_project != address(0), "Address must be non-empty");
    require(!isProjectAddress(_project), "Address already in list");
    _projects.push(_project);
    return true;
  }

  function getProjects() 
    public
    view 
    returns(address[] memory) 
  {
    return _projects;
  }


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



  function transferToVoting(
    address _project
  )
    internal
  {
    require(_project != address(0), "Address must be non-empty");
    require(isProjectAddress(_project), "Address is not in project list");
    _setBallotBalance(msg.sender, _balances[msg.sender]);
  }



  function returnFromVoting(
    address _project
  ) 
    public
    view
    returns(bool)
  {
     require(isProjectAddress(_project), "Address is not in project list");
     return isProjectAddress(_project);
  }
  
  //TODO:
  //implements this after making Ballot

  //Make transfer to voting after Ballot will be maked
  //Make "returning" tokens from project
}