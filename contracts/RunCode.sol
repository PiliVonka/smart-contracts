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
    event RunCodeForKey(string codeKey);
    
    // Variables
    mapping (string => CodeStatus) statuses;
    mapping (address => int256) balances;
    mapping (Task => address) taskToAddress;
    mapping (string => Task) tasks;
    mapping (string => address) codeToUser;

    // Modifiers
    modifier ifOracle {
        require(msg.sender == oracle);
    }

    modifier ifTaskOwner (string taskId) {
        require(msg.sender == tasks[taskId].owner);
    }
    
    // Constructor
    constructor (address _oracle) {
        oracle = _oracle;
    }

    // Functions 
    function registerTask(string taskId) {
        Task task = Task({ owner: msg.address, balance: msg.value });
        tasks[taskId] = task;
    }

    function withdrawAll(string memory taskId) ifTaskOwner(taskId) {
        Task task = tasks[taskId];
        msg.sender.transfer(task.balance);
        delete tasks[taskId];
    }

    function withdraw(string memory taskId, uint256 value) ifTaskOwner(taskId) {
        Task task = tasks[taskId];
        require(task.balance >= value);
        msg.sender.transfer(value);
        task.balance -= value;
    }

    function addSubmission(string memory codeKey) {

    }

    function sendStatus(string memory codeKey, string memory taskId, CodeStatus status) ifOracle returns(bool) {
        if (status == SUCCESS) {
            Task task = tasks[taskId];
            require(task.balance >= task.reward, "Balance is less than reward amount");
            address user = codeToUser[codeKey];
            user.transfer(task.reward);
        } else {
            delete codeToUser[codeKey];
        }
        emit receivedStatus(codeKey, taskId, status);
        return true;
    }

    function RunCode(string codeKey) {
        statuses[codeKey] = CodeStatus.PENDING;
        emit RunCodeForKey(codeKey);
    }

    function CheckStatus(string codeKey) returns(bool) {

        return true;
    }
}