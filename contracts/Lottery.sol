pragma solidity 0.8.14;

contract Lottethry {
    address[] public entries;
    uint256 public numEntries;
    uint256 public maxEntries = 10;
    uint256 public entryFee = 1 ether;
    uint256 public prize = 7.5 ether;
    bool public isOpen = false;

    uint256 public round = 0;

    // Events
    event LotteryEntry(address indexed _addr, uint256 indexed _round, uint256 _timestamp);
    event LotteryRound(
        address indexed _winner,
        uint256 indexed _round,
        uint256 _prize
    );

    constructor() {
        numEntries = 0;
        entries = new address[](maxEntries);
        isOpen = true;
    }

    function getEntries(address addr) public view returns (uint8) {
        uint8 count;
        for (uint8 i = 0; i < maxEntries; i++) {
            if (entries[i] == addr) {
                count++;
            }
        }
        return count;
    }

    function enter(uint256 _entries) public payable {
        require(isOpen, "Lottery is closed");
        if (numEntries + _entries > maxEntries) {
            revert("Lottery is full");
        }
        if (msg.value != entryFee * _entries) {
            revert("Not enough funds");
        }

        if (getEntries(msg.sender) >= 5) {
            revert("You have already entered 5 times");
        }

        for (uint256 i = 0; i < _entries; i++) {
            entries[numEntries] = address(msg.sender);
            numEntries++;
            emit LotteryEntry(msg.sender, round, block.timestamp);
        }

        if (numEntries == maxEntries) {
            // close the lottery to prevent further entries
            // And avoid the possibility of a malicious user
            // to exploit reentrancy
            isOpen = false;
            address winner = entries[7];

            numEntries = 0;
            delete entries;
            entries = new address[](maxEntries);
            round++;
            emit LotteryRound(winner, round, prize);
            payable(winner).transfer(prize);
            // Setting the lottery open after sending the prize
            isOpen = true;
        }
    }
}
