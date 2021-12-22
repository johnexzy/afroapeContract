// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */

contract AfroApes is Ownable {
    mapping(address => bool) private allAddresses;

    constructor() {
        allAddresses[msg.sender] = true;
    }

    function addWhiteListAddresses(address _address) public onlyOwner {
        allAddresses[_address] = true;
    }

    function verifyAddressIsOnWhiteList(address _address)
        public
        view
        returns (bool)
    {
        return allAddresses[_address];
    }

    function WhiteList(address[] memory _addre) public onlyOwner {
        for (uint256 i = 0; i < _addre.length; i++) {
            allAddresses[_addre[i]] = true;
        }
    }

    function getMyAddress() public view returns (bool) {
        return allAddresses[msg.sender];
    }
}
