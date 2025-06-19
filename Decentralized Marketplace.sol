// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedMarketplace {
    struct Item {
        uint256 id;
        address payable seller;
        string name;
        uint256 price;  // in wei
        bool sold;
    }

    uint256 public itemCount = 0;
    mapping(uint256 => Item) public items;

    event ItemListed(uint256 id, address seller, string name, uint256 price);
    event ItemPurchased(uint256 id, address buyer, uint256 price);

    // List a new item for sale
    function listItem(string memory _name, uint256 _price) public {
        require(_price > 0, "Price must be > 0");

        itemCount++;
        items[itemCount] = Item(itemCount, payable(msg.sender), _name, _price, false);

        emit ItemListed(itemCount, msg.sender, _name, _price);
    }

    // Buy an item by sending enough Ether
    function buyItem(uint256 _id) public payable {
        Item storage item = items[_id];

        require(_id > 0 && _id <= itemCount, "Invalid item ID");
        require(msg.value >= item.price, "Not enough Ether sent");
        require(!item.sold, "Item already sold");
        require(item.seller != msg.sender, "Seller cannot buy their own item");

        item.seller.transfer(item.price);  // Pay the seller
        item.sold = true;

        // Refund any excess Ether sent
        if (msg.value > item.price) {
            payable(msg.sender).transfer(msg.value - item.price);
        }

        emit ItemPurchased(_id, msg.sender, item.price);
    }

    // Get details of an item
    function getItem(uint256 _id) public view returns (Item memory) {
        require(_id > 0 && _id <= itemCount, "Invalid item ID");
        return items[_id];
    }
}
