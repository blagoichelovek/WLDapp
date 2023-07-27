//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSig {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    address[] public owners;
    mapping(address owner => bool) public isOwner;
    uint256 private required; //number of required approvals of owners per transaction

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) approved; //txId => owner => approved

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid number of required owners");
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "zero address");
            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false}));

        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function getApprovalCount(uint256 _txId) public view returns (uint256 count) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    function execute(uint256 _txId) external txExists(_txId) notExecuted(_txId) {
        require(getApprovalCount(_txId) >= required, "not enough approvals");
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit Execute(_txId);
    }

    function revoke(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }


    /////////////////////////
    ////Getter Functions////

    function getOwnersLength() external view returns (uint256) {
        return owners.length;
    }

    function getRequired() external view returns (uint256) {
        return required;
    }

    function getIsOwner(address _owner) external view returns (bool) {
        return isOwner[_owner];
    }

    function getTransactionAddress(uint256 _txId) external view returns (address to) {
        Transaction storage transaction = transactions[_txId];
        return (transaction.to);
    }

    function getTransactionValue(uint256 _txId) external view returns (uint256 value) {
        Transaction storage transaction = transactions[_txId];
        return (transaction.value);
    }

    function getTransactionData(uint256 _txId) external view returns (bytes memory data) {
        Transaction storage transaction = transactions[_txId];
        return (transaction.data);
    }

    function getTransactionExecuted(uint256 _txId) external view returns (bool executed) {
        Transaction storage transaction = transactions[_txId];
        return (transaction.executed);
    }

    function getApproved(uint256 _txId, address _owner) external view returns (bool) {
        return approved[_txId][_owner];
    }
}
