pragma solidity ^0.6.2;

contract RunCode {
    // Oracle
    address public oracle;

    // Structures
    struct Task {
        string id;
        address owner;       
        uint256 balance;
        uint256 reward;
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
    function registerTask(string memory taskId, uint256 reward) public payable {
        Task memory task = Task({ id: taskId, owner: msg.sender, balance: msg.value, reward: reward });
        tasks[taskId] = task;
    }

    function withdrawAll(string memory taskId) public ifTaskOwner(taskId) {
        Task memory task = tasks[taskId];
        msg.sender.transfer(task.balance);
        delete tasks[taskId];
    }

    function withdraw(string memory taskId, uint256 value) public ifTaskOwner(taskId) {
        Task memory task = tasks[taskId];
        require(task.balance >= value, "Balance is less than value");
        msg.sender.transfer(value);
        task.balance -= value;
    }

    function addSubmission(string memory taskId, string memory codeKey) public {

    }

    function sendStatus(string memory codeKey, string memory taskId, CodeStatus status) public ifOracle returns(bool) {
        if (status == CodeStatus.ACCEPTED) {
            Task memory task = tasks[taskId];
            require(task.balance >= task.reward, "Balance is less than reward");
            address payable user = codeToUser[codeKey];
            user.transfer(task.reward);
        } else {
            delete codeToUser[codeKey];
        }
        emit ReceivedStatus(codeKey, taskId, status);
        return true;
    }
}