// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenZeppelin/openzeppelin-contracts@4.7.3/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
    // Whitelist
    mapping(address => bool) private whitelist;

    function isInWhitelist(address account) public view returns (bool) {
        return whitelist[account];
    }

    function addWhitelist(address account) public onlyOwner {
        whitelist[account] = true;
    }

    function removeWhitelist(address account) public onlyOwner {
        whitelist[account] = false;
    }
}
