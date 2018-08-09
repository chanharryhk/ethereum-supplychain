pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./ERC721Basic.sol";

contract LuxuryStore {

    using SafeMath for uint256;

    // =====================================================================
    // VARIABLES
    // =====================================================================

    uint256 private itemID; // Keeps track of how many items has been registered

    struct Item {
        // needs unique identifier for item
        uint256 numOfTransfers;
        bool registered; // flag to check if luxury item has been registered before
        bool forSale;
        mapping (uint256 => uint256) price; // Price of the item according to a certain transfer
        mapping (uint256 => address) owners; // Owner of an item according to a certain transfer
    }

    mapping (uint256 => Item) public items; // Maps an item's id to the metadata of that particular item

    // Mapping from iteam address to owner
    mapping (uint256 => address) internal itemOwner;


    // =====================================================================
    // MODIFIERS
    // =====================================================================

    // Only current owner
    modifier onlyItemOwner(uint256 _itemNumber) {
        require(items[_itemNumber].owners[items[_itemNumber].numOfTransfers] == msg.sender);
        _;
    }

    //?
    modifier itemOnSale(uint256 _itemNumber) {
        require(items[_itemNumber].forSale == true);
        _;
    }

    // =====================================================================
    // CONSTRUCTOR
    // =====================================================================

    /**
    @dev Initialize the LuxuryStore contract by setting the number of items in existence as 0
    */
    constructor() public payable {
        itemID = 0;
    }

  // =====================================================================
  // ITEM
  // =====================================================================

    function registerItem(uint256 _itemPrice) public {
        require(items[itemID].registered == false);
        items[itemID].registered = true;
        items[itemID].numOfTransfers = 0;  // initializing the number of transfers from this item is 0
        items[itemID].forSale = true;
        items[itemID].price[0] = _itemPrice; // setting the price of an item
        items[itemID].owners[0] = msg.sender; // initializing the original owner of the item is the person who sent the txn
        itemID += 1;
    }

    function sellItem(uint256 _itemNumber, uint256 _itemPrice) public onlyItemOwner(_itemNumber){
        // require(items[_itemNumber].forSale == true);
        items[_itemNumber].forSale = true;
        items[_itemNumber].price[items[_itemNumber].numOfTransfers] = _itemPrice;
    }

    function buyItem(uint256 _itemNumber) public payable itemOnSale(_itemNumber){
        // require(msg.value >= items[_itemNumber].price[items[_itemNumber].numOfTransfers]); // Ether sent in must match item price listing
        items[_itemNumber].owners[items[_itemNumber].numOfTransfers - 1].transfer(msg.value); // Sending Ether to previous owner
        items[_itemNumber].forSale = false; // Not for sale anymore
        items[_itemNumber].numOfTransfers += 1; // Increasing number of transfers on the item
        items[_itemNumber].owners[items[_itemNumber].numOfTransfers] = msg.sender; // Moving ownership to item purchaser
    }

    function itemCount() public view returns(uint256) {
        return itemID;
    }

    function itemPrice(uint256 _itemNumber) public view returns(uint256) {
        return items[_itemNumber].price[items[_itemNumber].numOfTransfers];
    }

    function itemAvailability(uint256 _itemNumber) public view returns(bool){
        return items[_itemNumber].forSale;
    }

    function ownerOfItem(uint256 _itemNumber, uint256 _transferNum) public view returns(address){
        return items[_itemNumber].owners[_transferNum];
    }
}