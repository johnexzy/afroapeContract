// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IAfroApesOrigin {

    /**
      * @dev represents the maximum for number of apes available in this collection
      * *for the origin collection the max apes is proposed to 160.
      *     - 50 OG,
      *     - 100 Marketplaces Auction,
      *     - 10 For Team,
      */
    uint256 public constant MAX_APES;

    /**
      * @dev returns true if OG sale is active
      */
    bool public saleIsActive;

    /**
      * @dev triggered when on OGMint
      */
    event OGMinted(address indexed to, uint256 apeId);


    /**
      * @dev set some apes aside (e.g. set 10 apes aside for Team).
      * * This function mints specified number of apes to the caller
      * -Requirements:
      * -- @param amount: number of apes to reserve
      * 
      * @dev This function should be called only by the owner. 
      */
    function reserveApes(uint256 amount) public ;

    /**
      * @dev adds array of addresses to whitelists (OG addresses)
      *     - 50 OG, 50 addresses
      * @param _addre: array of addresses
      */
    function addAddressesForWhiteList(address[] memory _addre) public ;

    /*
     * Pause OG sale if active, make active if paused
     * usecase: emergency.
     */
    function flipSaleState() public;
    
    /**
     * @dev OG mint. Only for OG whitelisted adresses
     */
    function mintApe() public payable;

    /**
     * Set Base URI. 
     *  usecase: set or remove mask on all token
     * @param _baseURI_: url to metadata. must have closing "/"
     *          e.g : https://example.com/
     */
    function setBaseURI(string memory _baseURI_) public ;

    /**
      * @dev redirect a token metadata to a different url
      * usecase: emergency
      *
      * @param maskURI: url to be redirected
      * @param tokenId: token id to mask
      */
    function maskAToken(string memory maskURI, uint256 tokenId) public;
    
    /**
      * @dev revert any redirect made on token
      *
      * @param tokenId: token id to un-mask
      */
    function unMaskAToken(uint256 tokenId) public ;
    
    /**
      *@dev returns total OG minted
      */
    function totalOGsMinted() public view returns (uint256);

    /**
      * @dev returns total Apes Minted
      * - max supply is MAX_APES
      */
    function totalSupply() public view returns (uint256);

    /**
      * @dev set price for OG minting
      * set OG_MINT_PRICE
      */
    function setMintPrice(uint256 price) public;

    /**
      * @dev return price in ETH for OG minting
      */
    function getMintPriceInEth() public view returns (uint256);

    /**
      * @dev withdraw all funds from smart contract
      */
    function withdraw() external;
    
    /**
      * @dev withdraw some funds from smart contract
      */
    function withdrawOnly(uint256 amount) external

}