pragma solidity ^0.4.24;

contract luxuryStore {
    uint256 private itemID; // Keeps track of how many items has been registered

    //Only current owner

    modifier onlyItemOwner(uint256 _itemNumber) {
        require(registeredItem[_itemNumber].owners[registeredItem[_itemNumber].numOfTransfers] == msg.sender);
        _;
    }

    modifier itemOnSale(uint256 _itemNumber) {
        require(registeredItem[_itemNumber].forSale == true);
        _;
    }

    mapping (uint256 => luxuryItem) registeredItem; // Maps an item's  to the metadata of that particular item

    struct luxuryItem {
        uint256 numOfTransfers;
        bool forSale;
        mapping (uint256 => uint256) price; // Price of the item according to a certain transfer
        mapping (uint256 => address) owners; // Owner of an item according to a certain transfer
    }

    constructor() public {
        itemID = 0; // Set the number of items in existance to be 0
    }

    function registerItem(uint256 _itemPrice) public {
        registeredItem[itemID].numOfTransfers = 0;  // initializing the number of transfers from this item is 0
        registeredItem[itemID].forSale = true;
        registeredItem[itemID].price[0] = _itemPrice; // setting the price of an item
        registeredItem[itemID].owners[0] = msg.sender; // initializing the original owner of the item is the person who sent the txn
        itemID += 1;
    }

    function sellItem(uint256 _itemNumber, uint256 _itemPrice) public onlyItemOwner(_itemNumber) {
        registeredItem[_itemNumber].forSale = true;
        registeredItem[_itemNumber].price[registeredItem[_itemNumber].numOfTransfers] = _itemPrice;
    }

    function buyItem(uint256 _itemNumber) public payable onlyItemOwner(_itemNumber) itemOnSale(_itemNumber){
        require(msg.value == registeredItem[_itemNumber].price[registeredItem[_itemNumber].numOfTransfers]); // Ether sent in must match item price listing
        registeredItem[_itemNumber].owners[registeredItem[_itemNumber].numOfTransfers - 1].transfer(msg.value); // Sending Ether to previous owner
        registeredItem[_itemNumber].forSale = false; // Not for sale anymore
        registeredItem[_itemNumber].numOfTransfers += 1; // Increasing number of transfers on the item
        registeredItem[_itemNumber].owners[registeredItem[_itemNumber].numOfTransfers] = msg.sender; // Moving ownership to item purchaser
    }

}
