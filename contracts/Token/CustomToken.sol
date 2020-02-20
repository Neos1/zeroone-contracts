pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../lib/Ownable.sol";
import "../ZeroOne/IZeroOne.sol";

/**
@title CustomToken
@dev Contract implements custom tokens for ZeroOne 
*/
contract CustomToken is Ownable {
    mapping (address => uint256) private balances;

    mapping (address => mapping (address => bool)) private tokenLocks;

    mapping (address => bool) private projectExists;

    mapping (address => uint) private projectIndexes;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;

    address[] holders;

    address[] projects;

    event Transfer(address from, address to, uint256 count);

    event TokenLocked(address project, address user);

    event HolderRemoved(address holder);

    event HolderAdded(address holder);

    event ProjectAdded(address project);

    event ProjectRemoved(address project);

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
        balances[msg.sender] = totalSupply;
        holders.push(msg.sender);
        projects.push(address(0));
    }

    modifier onlyZeroOne(address _caller) {
        require(projectExists[_caller] = true, "Address not contains in projects");
        _;
    }

    modifier onlySelf() {
        require(msg.sender == address(this), "Sender is not token contract");
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


    /**
     * @dev getting balance of tokens for {_user}
     * @param _user address of user 
     * @return balance
     */
    function balanceOf(
        address _user
    ) 
        public 
        view 
        returns (uint256 balance) 
    {
        return balances[_user];
    }

    /**
     * @dev add ballot project to list
     * @param _project address of ballot project
     * @return success
     */
    function addToProjects(
        address _project
    ) 
        internal
        onlyOwner
        returns (bool success)
    {
        require(_project != address(0), "Address must be non-empty");
        require(!projectExists[_project], "Address already in list");
        projects.push(_project);
        projectExists[_project] = true;
        projectIndexes[_project] = projects.length - 1;
        emit ProjectAdded(_project);
        return true;
    }

    /**
     * @dev removing projects from the list
     * can called only by project, which will be removed
     * @param _project address of ZeroOne project
     */
    function removeFromProjects(
        address _project
    ) 
        public 
        onlyZeroOne(_project)
    {
        uint index = projectIndexes[_project];
        projectExists[_project] = false;
        projects[index] = projects[projects.length - 1];
        projects.pop();
        emit ProjectRemoved(_project);
    }

    /**
     * @dev Transfers tokens from _sender to _recipient
     * @param _sender address of token sender
     * @param _recipient address of recipient of tokens
     * @param _count count of tokens, which will be transferred
     */
    function transfer(
        address _sender, 
        address _recipient, 
        uint256 _count
    )
        internal 
    {
        require(balances[_sender] >= _count, "Value must be less or equal user balance");
        uint256 newSenderBalance = balances[_sender] - _count;
        uint256 newRecipientBalance = balances[_recipient] + _count;

        if (balances[_recipient] == 0) {
            addHolder(_recipient);
        }

        balances[_sender] = newSenderBalance;
        balances[_recipient] = newRecipientBalance;

        if (newSenderBalance == 0) {
            removeHolder(_sender);
        }
        emit Transfer(_sender, _recipient, _count);
    }

    /**
     * @dev Function, which find ZeroOne projects, where user is voted
     * and updating votes in this project
     * @param _user address of user, which vote will be updated
     */
    function onTokenTransfer(
        address _user
    ) 
        internal
        onlySelf
    {
        for (uint i = 0; i < projects.length; i++) {
            if (isTokenLocked(projects[i], _user)) {
                IZeroOne project = IZeroOne(projects[i]);
                project.updateUserVote(address(this), _user, balanceOf(_user));
            }
        }
    }

    /**
     * @dev removing holder from the list
     * @param _holder holder, which will be removed from list
     */
    function removeHolder(
        address _holder
    ) 
        internal
        onlySelf
    {
        for (uint i = 0; i < holders.length; i++) {
            if (_holder == holders[i]) {
                holders[i] = holders[holders.length - 1];
                delete holders[holders.length - 1];
                emit HolderRemoved(_holder);
            }
        }
    }

    /**
     * @dev adding holder to the list
     * @param _newHolder new holder, which will be added to list
     */
    function addHolder(
        address _newHolder
    ) 
        internal
        onlySelf
    {
        holders.push(_newHolder);
        emit HolderAdded(_newHolder);
    }

    /**
     * @dev Set lock status of user tokens in project
     * @param _project address of ZeroOne project
     * @param _user address of user
     * @return status
     */
    function lockTokens(
        address _project,
        address _user
    )
        internal
        returns (bool status) 
    {
        tokenLocks[_project][_user] = true;
        emit TokenLocked(_project, _user);

        return tokenLocks[_project][_user];
    }


    /**
     * @dev Set unlock status of user tokens in project
     * @param _project address of ZeroOne project
     * @param _user address of user
     * @return status 
     */
    function unlockTokens(
        address _project,
        address _user
    )
        internal
        returns (bool status) 
    {
        tokenLocks[_project][_user] = false;
        return !tokenLocks[_project][_user];
    }

    /**
     * @dev getter for status of user tokens lock in project
     * @param _project address of ZeroOne project
     * @param _user address of user
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
        return tokenLocks[_project][_user];
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
        return projects;
    }

    /**
     * @dev check if address using as project
     * @param _address address, which will be checked
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

        for (uint i = 0; i < projects.length; i++) {
            address ballotAddress = projects[i];
            if (ballotAddress == _address) {
                isProject = true; 
                break;
            } else {
                isProject = false;
            }
        }
    }

    /**
     * @dev lock tokens of msg.sender and sending vote to ballot
     * @param _sender address of user, which token will be locked
     * @param _reciepient address of ZeroOne project
     * @param _count count of tokens
     */
    function transferFrom(
        address _sender,
        address _reciepient,
        uint256 _count
    )
        public
        returns (bool)
    {
        require(_sender != address(0), "Address must be non-empty");
        require(balanceOf(_sender) > 0, "Balance of sender must be greater, then zero");

        if (msg.sender == owner()) {
            transfer(_sender, _reciepient, _count);
            onTokenTransfer(_sender);
            onTokenTransfer(_reciepient);
        } else if (isProjectAddress(msg.sender)) {
            lockTokens(_reciepient, _sender);
        }
        return true;
    }

    /**
     * @dev unlocks the tokens of msg.sender
     * @param _project address of project
     * @return isLocked
     */
    function revoke(
        address _project
    ) 
        public
        returns(bool isLocked)
    {
        require(isProjectAddress(_project), "Address is not in project list");
        unlockTokens(_project, msg.sender);
        return !isTokenLocked(_project, msg.sender);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`_newOwner`).
     * Can only be called by the ZeroOne project.
     * @param _newOwner account, which will be setted as new owner
     */
    function transferOwnership(address _newOwner) public onlyZeroOne(msg.sender) {
        _transferOwnership(_newOwner);
    }

    
    // TODO:implements this after making Ballot
    // add check for address (address is project ?)
}
