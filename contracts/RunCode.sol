pragma solidity ^0.6.2;

contract RunCode {
    // Oracle
    address public oracle;

    // Structures
    struct Task {
        string id;
        address owner;       
        uint256 balance;
        uint256 successReward;
        uint256 submissionPrice;
    }
    
    enum CodeStatus {
        PENDING, // 0
        FAIL, // 1
        ACCEPTED // 2
    }

    // Events
    event ReceivedStatus(string codeKey, string taskId, CodeStatus status);

    // Variables
    mapping (string => CodeStatus) internal statuses;
    mapping (address => int256) internal balances;
    mapping (string => Task) internal tasks;
    mapping (string => address payable) internal codeToUser;

    // Modifiers
    modifier ifOracle {
        require(msg.sender == oracle, "Sender is not oracle");
        _;
    }

    modifier ifTaskOwner (string memory taskId) {
        require(msg.sender == tasks[taskId].owner, "Sender is not owner");
        _;
    }

    modifier ifTaskExists (string memory taskId) {
        require(keccak256(abi.encodePacked(taskId)) == keccak256(abi.encodePacked(tasks[taskId].id)), "Given taskId does not exist");
        _;
    }
    
    modifier ifTaskNotExists (string memory taskId) {
        require(keccak256(abi.encodePacked(taskId)) != keccak256(abi.encodePacked(tasks[taskId].id)), "Given taskId already exists");
        _;
    }

    // Constructor
    constructor (address _oracle) public {
        oracle = _oracle;
    }

    // Functions 
    function registerTask(
        string memory taskId,
        uint256 successReward,
        uint256 submissionPrice
    ) 
        public
        payable
        ifTaskNotExists(taskId)
        returns (bool)
    {
        Task memory task = Task({ 
            id: taskId, 
            owner: msg.sender,
            balance: msg.value,
            successReward: successReward,
            submissionPrice: submissionPrice
        });
        tasks[taskId] = task;

        return true;
    }

    // Stores the address of submitters
    function addSubmission(
        string memory taskId, 
        string memory codeKey
    )
        public 
        payable 
        returns(bool) 
    {
        Task memory task = tasks[taskId];
        require(msg.value >= task.submissionPrice, "Value is less then the price");
        codeToUser[codeKey] = msg.sender;
        return true;
    }

    // Executed when result is ready for a code
    function putStatusResult(
        string memory taskId,
        string memory codeKey,
        CodeStatus status
    )
        public 
        ifOracle
        ifTaskExists (taskId)
        returns(bool) 
    {
        if (status == CodeStatus.ACCEPTED) {
            Task memory task = tasks[taskId];
            require(task.balance >= task.successReward, "Balance is less than reward");
            address payable user = codeToUser[codeKey];
            user.transfer(task.successReward);
        } else {
            delete codeToUser[codeKey];
        }

        emit ReceivedStatus(codeKey, taskId, status);
        return true;
    }

    function getBalance(
        string memory taskId
    ) 
        public
        ifTaskOwner(taskId)
        returns (uint256)
    {
        Task memory task = tasks[taskId];
        return task.balance;
    }

    function withdrawAll(
        string memory taskId
    ) 
        public 
        ifTaskOwner(taskId) 
    {
        Task memory task = tasks[taskId];
        msg.sender.transfer(task.balance);
        delete tasks[taskId];
    }

    function withdraw(
        string memory taskId,
        uint256 value
    ) 
        public 
        ifTaskOwner(taskId)
        returns (bool)
    {
        Task memory task = tasks[taskId];
        require(task.balance >= value, "Balance is less than the value");
        msg.sender.transfer(value);
        task.balance -= value;
    }
}