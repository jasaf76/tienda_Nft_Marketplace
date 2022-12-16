// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaDapp {
    address public owner;
    uint256 private secureAddPercent = 5;
    address private noOne = address(0);
    IERC20 private token;

    struct User {
        string name;
        string contact;
        bool updated;
        uint256 total_products;
        uint256[] products;
    }

    struct Product {
        string name;
        string desc;
        string section;
        uint256 price;
        address owner;
        address reserved_by;
    }

    Product[] private products;
    mapping(address => User) public users;

    uint256 private _totalUsers;

    event ProductPurchased(address indexed user, address owner, uint256 price);
    event ProductAdded(address indexed owner, string name, uint256 price);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        _totalUsers = 0;
    }

    function setSecureAddPercent(uint256 percent) external isOwner {
        secureAddPercent = percent;
    }

    function getSecureAddPercent() private view isOwner returns (uint256) {
        return secureAddPercent;
    }

    function __percentValue(uint256 _amount) public view returns (uint256) {
        return (secureAddPercent * _amount) / 100;
    }

    function __amount(uint256 _amount) private pure returns (uint256) {
        return _amount * (10**18);
    }

    function addProduct(
        string memory name,
        string memory desc,
        string memory section,
        uint256 price
    ) public {
        transferTockens(
            address(this),
            __amount(__percentValue(price)),
            msg.sender
        );
        products.push(
            Product(name, desc, section, __amount(price), msg.sender, noOne)
        );
        emit ProductAdded(msg.sender, name, __amount(price));
    }

    function transferTockens(
        address _owner,
        uint256 _price,
        address _buyer
    ) private {
        require(
            _price <= token.balanceOf(_buyer),
            "Es sind nicht genung Tokens um zu transferiren"
        );
        require(
            token.allowance(_buyer, address(this)) >= _price,
            "Es sind nicht genung Original Tokens um zu transferiren"
        );

        bool sent = token.transferFrom(_buyer, _owner, _price);
        require(sent, "Nicht gesendet");
    }

    function updateProductPrice(uint256 product_id, uint256 price) public {
        require(msg.sender != noOne);
        Product storage product = products[product_id];
        require(msg.sender == product.owner);
        require(product.reserved_by == noOne);
        product.price = __amount(price);
    }

    function updateUserContact(string memory contact, string memory name)
        public
    {
        require(msg.sender != noOne);
        User storage user = users[msg.sender];
        user.contact = contact;
        user.name = name;

        if (!user.updated) _totalUsers++;

        user.updated = true;
    }

    function buyProduct(uint256 product_id) public {
        Product storage product = products[product_id];
        require(
            msg.sender != product.owner,
            "Sie koennen nicht ihre Eigenen NFTS kaufen"
        );
        transferTockens(product.owner, product.price, msg.sender);
        User storage buyer = users[msg.sender];
        buyer.total_products += 1;
        buyer.products.push(product_id);
        product.reserved_by = msg.sender;

        emit ProductPurchased(msg.sender, product.owner, product.price);
    }

    function totalUsers() public view returns (uint256) {
        return _totalUsers;
    }

    function getProducts() public view returns (Product[] memory) {
        return products;
    }

    function getProduct(uint256 product_id)
        public
        view
        returns (Product memory)
    {
        return products[product_id];
    }

    function getUser(address userAddress) public view returns (User memory) {
        return users[userAddress];
    }

    function withdrawBNB(address payable account) external isOwner {
        (bool success, ) = account.call{value: address(this).balance}("");
        require(success);
    }

    function withdraw(address to, uint256 amount) external isOwner {
        require(token.transfer(to, amount));
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}
