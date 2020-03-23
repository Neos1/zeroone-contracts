pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../lib/Ownable.sol";
import "../ZeroOne/Ballots/IBallots.sol";

/**
 * @title CustomToken
 * @dev Contract implements custom tokens for ZeroOne 
 */
contract CustomToken is Ownable {
    mapping (address => uint256) private balances;

    mapping (address => mapping (address => bool)) private tokenLocks;

    mapping (address => bool) private projectExists;

    mapping (address => uint) private projectsIndexes;

    mapping (address => uint) holdersIndexes;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;

    address[] holders;

    address[] projects;

    uint PROJECTS_LIMIT = 10;

    event Transfer(address from, address to, uint256 count);

    event TokensLocked(address project, address user);

    event TokensUnlocked(address project, address user);

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
        projects.push(address(0)); // skip first 
    }

    modifier onlyZeroOne {
        require(projectExists[msg.sender] == true, "Project list does not contain provided address");
        _;
    }

    /**
     * @dev returns amount of tokens
     * @return totalSupply
     */
    function totalSupply() public view returns (uint256) { return _totalSupply; }

    /**
     * @dev returns name of tokens
     * @return name of token
     */
    function name() public view returns(string memory) { return _name; }

    /**
     * @dev returns symbol of tokens
     * @return symbol of token
     */
    function symbol() public view returns(string memory) { return _symbol; }

    /**
     * @dev returns list of holders
     * @return holders 
     */
    function getHolders() public view returns (address[] memory) { return holders; } 

    /**
     * @dev gets balance of tokens for {_user}
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
     * @dev adds project to list
     * @param _project address of ballot project
     * @return success
     */
    function addToProjects(
        address _project
    ) 
        public
        returns (bool success)
    {
        require(_project != address(0), "Address must be non-empty");
        require(!projectExists[_project], "Project is already in the list");
        require(projects.length < PROJECTS_LIMIT+1, "Limit of projects are riched");
        projects.push(_project);
        projectExists[_project] = true;
        projectsIndexes[_project] = projects.length - 1;
        emit ProjectAdded(_project);
        return true;
    }

    /**
     * @dev removes project from list
     * can called only by project, which will be removed
     * @param _project address of ZeroOne project
     */
    function removeFromProjects(
        address _project
    ) 
        public 
        onlyZeroOne
    {
        require(isProjectAddress(_project), "Provided address is not in projects list");
        uint index = projectsIndexes[_project];
        address lastProjectInList = projects[projects.length - 1];

        projectExists[_project] = false;
        projectsIndexes[_project] = 0;

        projects[index] = lastProjectInList;
        projectsIndexes[lastProjectInList] = index;

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
     * @dev finds ZeroOne projects, where user has voted and updates its votes in this project
     * @param _user address of user, which vote will be updated
     */
    function onTokenTransfer(
        address _user
    ) 
        internal
    {
        for (uint i = 1; i < projects.length - 1; i++) {
            if (isTokenLocked(projects[i], _user)) {
                IBallots project = IBallots(projects[i]);
                uint256 newBalance = balanceOf(_user);
                project.updateUserVote(address(this), _user, newBalance);
            }
        }
    }

    /**
     * @dev Removes holder from the list
     * @param _holder holder, which will be removed from list
     */
    function removeHolder(
        address _holder
    ) 
        internal
    {
        uint index = holdersIndexes[_holder];
        address lastHolderInList = holders[holders.length - 1];

        holders[index] = lastHolderInList;
        holdersIndexes[lastHolderInList] = index;
        holders.pop();
        emit HolderRemoved(_holder);
    }

    /**
     * @dev Adds holder to the list
     * @param _newHolder new holder, which will be added to list
     */
    function addHolder(
        address _newHolder
    ) 
        internal
    {
        holders.push(_newHolder);
        holdersIndexes[_newHolder] = holders.length - 1;
        emit HolderAdded(_newHolder);
    }

    /**
     * @dev Locks user tokens in project
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
        require(isProjectAddress(_project), "Provided address is not in project list");
        require(!tokenLocks[_project][_user], "Tokens in this project is already locked");
        tokenLocks[_project][_user] = true;
        emit TokensLocked(_project, _user);
        return tokenLocks[_project][_user];
    }


    /**
     * @dev Unlocks user tokens in project
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
        require(isProjectAddress(_project), "Provided address is not in project list");
        tokenLocks[_project][_user] = false;
        emit TokensUnlocked(_project, _user);
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
    * @dev Gets projects list
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
     * @dev Checks if address is used as project
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
        isProject = projectExists[_address];
    }

    /**
     * @dev Locks tokens of msg.sender and sends vote to ballot
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
        require(
            (msg.sender == owner() || isProjectAddress(msg.sender)), 
            "This operation is not allowed for this address"
        );
        require(_sender != address(0), "Address must be non-empty");
        require(balanceOf(_sender) >= _count, "Balance of sender must be greater, then amount");

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
     * @param _user address of user
     * @return isUnlocked
     */
    function revoke(
        address _project,
        address _user
    )
        public
        returns(bool isUnlocked)
    {
        require(isProjectAddress(_project), "Address is not in project list");
        IBallots project = IBallots(_project);
        require(
            isTokenLocked(_project, _user),
            "User not voted, nothing to unlock"
        );
        
        project.updateUserVote(address(this), msg.sender, 0);
        unlockTokens(_project, msg.sender);
        return !isTokenLocked(_project, msg.sender);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`_newOwner`).
     * Can only be called by the ZeroOne project.
     * @param _newOwner account, which will be setted as new owner
     */
    function transferOwnership(address _newOwner) public onlyZeroOne {
        _transferOwnership(_newOwner);
    }

    // TODO:implements this after making Ballot
    // add check for address (address is project ?)
}
