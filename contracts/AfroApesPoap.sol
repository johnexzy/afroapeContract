// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// import "./stringutils.sol";
//
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */

contract AfroApesPoap is ERC1155, Pausable, Ownable {
    string  public name = "AfroApes Poap";
    string  public symbol = "Afro Poap";
    string private _contractUri;
    constructor() ERC1155("ipfs://QmUE8yTURyYwydBtLngUL3B7gwMk3v2FHt1stKaNDuW35n/{id}.json"){

    }
    
    function mintSingle(address account, uint256 id, uint256 amount) public {
        _mint(account, id, amount, "");
    }

    function mintMultiPoap(address[] memory accounts, uint256 id, uint256 amount) public onlyOwner() {
        for(uint i = 0; i < accounts.length; i++){
            mintSingle(accounts[i], id, amount);
                
        }
    }

    /**
        When a new metadata is uploaded set the ipfs CID as newUri

    */
    function changeBaseURI(string memory newuri) public onlyOwner() {
        _setURI(newuri);
    }

    function changeName (string memory newName) public onlyOwner() {
        name = newName;
    }

    function changeSymbol (string memory newSymbol) public onlyOwner() {
        symbol = newSymbol;
    }
    function pause() public onlyOwner() {
        _pause();
    }

    function unpause() public onlyOwner() {
        _unpause();
    }


    function setContractURI(string memory uri) public onlyOwner() {
        _contractUri = uri;
    }

    /*
    This handles details about collection. Image, Name and description

    */
    function contractURI() public view returns (string memory) {
        return _contractUri;
    }
}