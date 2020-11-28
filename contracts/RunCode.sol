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
        PENDING,
        FAIL,
        ACCEPTED
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
    
    // Constructor
    constructor (address _oracle) public {
        oracle = _oracle;
    }

    // Functions 
    function registerTask(
        string memory taskId,
        uint256 successReward,
        uint256 submissionPrice
    ) public payable returns (bool) {
        // string memory temp = tasks[taskId].id;
        require(keccak256(abi.encodePacked(taskId)) != keccak256(abi.encodePacked(tasks[taskId].id)), "Given taskId already exists");

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

    function withdrawAll(string memory taskId) public ifTaskOwner(taskId) {
        Task memory task = tasks[taskId];
        msg.sender.transfer(task.balance);
        delete tasks[taskId];
    }

    function withdraw(string memory taskId, uint256 value) public ifTaskOwner(taskId) {
        Task memory task = tasks[taskId];
        require(task.balance >= value, "Balance is less than the value");
        msg.sender.transfer(value);
        task.balance -= value;
    }

    function addSubmission(string memory taskId, string memory codeKey) public payable returns(bool) {
        Task memory task = tasks[taskId];
        require(msg.value >= task.submissionPrice, "Value is less then the price");
        codeToUser[codeKey] = msg.sender;
        return true;
    }

    function putStatusResult(string memory taskId, string memory codeKey, CodeStatus status) public ifOracle returns(bool) {
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
}