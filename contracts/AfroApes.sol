// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AfroApes is ERC721, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public afroApesPROVENANCE = "";

    uint256 public startingIndexBlock;

    uint256 public startingIndex;

    uint256 private APE_PRICE = 50000000000000000; //0.05 ETH

    uint256 public constant MAX_APE_PURCHASE = 10;

    uint256 public MAX_APES;

    bool public saleIsActive = true;

    uint256 public REVEAL_TIMESTAMP;

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) private maskedApes;

    // Base URI
    string private _ApesBaseURI =
        "https://gateway.pinata.cloud/ipfs/QmSm5iRyvDa4afh4JXQQFoMLQGT81QXDk6q2SqCLxMCmFZ/";

    constructor()
        // string memory name,
        // string memory symbol,
        // uint256 maxNftSupply,
        // uint256 saleStart
        ERC721("ApesOrigin", "Apes")
    {
        MAX_APES = 200;
        REVEAL_TIMESTAMP = 1 + (86400 * 9);
    }

    // function withdraw() public onlyOwner {
    //     uint256 balance = address(this).balance;
    //     msg.sender.transfer(balance);
    // }

    /**
     * Set some Bored Apes aside
     */
    function reserveApes(uint256 reserve) public onlyOwner {
        uint256 i;
        for (i = 0; i < reserve; i++) {
            _safeMint(owner(), totalSupply());
            // _setRoyalties(totalSupply(), payable(owner()), 1000);
            _tokenIds.increment();
        }
    }

    /**
     * Pass a unix timestamp.
     */
    function setRevealTimestamp(uint256 revealTimeStamp) public onlyOwner {
        REVEAL_TIMESTAMP = revealTimeStamp;
    }

    /*
     * Set provenance once it's calculated
     */
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        afroApesPROVENANCE = provenanceHash;
    }

    /*
     * Pause sale if active, make active if paused
     */
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
     * Mints Afro Apes
     */
    function mintApe(uint256 numberOfApes) public payable {
        require(saleIsActive, "Sale must be active to mint Ape");
        require(
            numberOfApes <= MAX_APE_PURCHASE,
            "Can only mint 10 tokens at a time"
        );
        require(numberOfApes > 0, "Must mint at least one Ape");
        require(
            totalSupply().add(numberOfApes) <= MAX_APES,
            "Purchase would exceed max supply of Apes"
        );

        require(
            APE_PRICE.mul(numberOfApes) <= msg.value,
            "Ether value sent is not correct"
        );

        for (uint256 i = 0; i < numberOfApes; i++) {
            // uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_APES) {
                _safeMint(msg.sender, totalSupply());
                // _setRoyalties(totalSupply(), payable(owner()), 1000);
                _tokenIds.increment();
            }
        }
        if (msg.value > APE_PRICE.mul(numberOfApes)) {
            Address.sendValue(
                payable(msg.sender),
                msg.value - APE_PRICE.mul(numberOfApes)
            );
        }
        // If we haven't set the starting index and this is either 1) the last saleable token or 2) the first token to be sold after
        // the end of pre-sale, set the starting index block
        if (
            startingIndexBlock == 0 &&
            (totalSupply() == MAX_APES || block.timestamp >= REVEAL_TIMESTAMP)
        ) {
            startingIndexBlock = block.number;
        }
    }

    /**
     * Set the starting index for the collection
     */
    function setStartingIndex() public {
        require(startingIndex == 0, "Starting index is already set");
        require(startingIndexBlock != 0, "Starting index block must be set");

        startingIndex = uint256(blockhash(startingIndexBlock)) % MAX_APES;
        // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
        if (block.number.sub(startingIndexBlock) > 255) {
            startingIndex = uint256(blockhash(block.number - 1)) % MAX_APES;
        }
        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex.add(1);
        }
    }

    /**
     * Set the starting index block for the collection, essentially unblocking
     * setting starting index
     */
    function emergencySetStartingIndexBlock() public onlyOwner {
        require(startingIndex == 0, "Starting index is already set");

        startingIndexBlock = block.number;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory _tokenURI = _tokenURIs[tokenId];

        // if token is masked incase of emergency, escape baseUri and return masked URI
        //
        if (maskedApes[tokenId]) {
            return _tokenURI;
        }
        return
            bytes(baseURI()).length > 0
                ? string(
                    abi.encodePacked(baseURI(), tokenId.toString(), ".json")
                )
                : "";
    }

    /**
     * @dev Returns the base URI set via {_setBaseURI}. This will be
     * automatically added as a prefix in {tokenURI} to each token's URI, or
     * to the token ID if no specific URI is set for that token ID.
     */
    function baseURI() public view virtual returns (string memory) {
        return _ApesBaseURI;
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _ApesBaseURI = baseURI_;
    }

    /**
     * Set Base URI. set blurly URI to hide Apes until reveal day.
     */
    function setBaseURI(string memory _baseURI_) public onlyOwner {
        _setBaseURI(_baseURI_);
    }

    function maskAToken(string memory maskURI, uint256 tokenId)
        public
        onlyOwner
    {
        _setTokenURI(tokenId, maskURI);
        maskedApes[tokenId] = true;
    }

    function unMaskAToken(uint256 tokenId) public onlyOwner {
        _setTokenURI(tokenId, "");
        maskedApes[tokenId] = false;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function setApeMintPrice(uint256 price) public onlyOwner {
        APE_PRICE = price;
    }
    function getApeMintPrice() public view returns (uint256){
        return APE_PRICE;
    }


    function setMaxApes(uint256 supply) public onlyOwner {
        MAX_APES = supply;
    }
    /**
     * @dev Withdraw all funds from contracts.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(msg.sender), balance);
    }
    /**
     * @dev Withdraw funds from contracts.
     */
    function withdrawOnly(uint256 amount) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance >= amount, "Amount exceeds total funds in contract" );
        Address.sendValue(payable(msg.sender), amount);
    }
}
