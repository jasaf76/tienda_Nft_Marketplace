// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./Address.sol";
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

    function __percentValue(uint _amount) public view returns (uint256) {
        return (secureAddPercent * _amount) / 100;
    }

    function __amount(uint256 _amount) private pure returns (uint256) {
        return _amount * (10**18);
    }

    function addProduct(
        string memory name,
        string memory dataHash,
        string memory section,
        uint256 price
    ) external {
        transferTokens(
            address(this),
            __amount(__percentValue(price)),
            _msgSender()
        );

        products.push(
            Product(
                name,
                dataHash,
                section,
                __amount(price),
                _msgSender(),
                noOne
            )
        );
        emit ProductAdded(_msgSender(), name, __amount(price));
    }

    function transferTokens(
        address _owner,
        uint256 _price,
        address _buyer
    ) private {
        require(
            _price <= token.balanceOf(_buyer),
            "Insuficent tokens to make transfer"
        );
        require(
            token.allowance(_buyer, address(this)) >= _price,
            "Insuficent allowence to make reserve"
        );

        bool sent = token.transferFrom(_buyer, _owner, _price);
        require(sent, "Not sent");
    }

    function updateProductPrice(uint256 product_id, uint256 price) external {
        require(_msgSender() != noOne);
        Product storage product = products[product_id];
        require(_msgSender() == product.owner);
        require(product.reserved_by == noOne);
        product.price = __amount(price);
    }

    function updateUserContact(string memory dataHash) external {
        require(_msgSender() != noOne);
        User storage user = users[_msgSender()];
        user.dataHash = dataHash;

        if (!user.updated) _totalUsers++;

        user.updated = true;
    }

    function buyProduct(uint256 product_id) external {
        Product storage product = products[product_id];
        require(
            _msgSender() != product.owner,
            "You cannot buy your own products"
        );
        transferTokens(product.owner, product.price, _msgSender());
        User storage buyer = users[_msgSender()];
        buyer.total_products += 1;
        buyer.products.push(product_id);
        product.reserved_by = _msgSender();

        emit ProductPurchased(_msgSender(), product.owner, product.price);
    }

    function totalUsers() external view returns (uint256) {
        return _totalUsers;
    }

    function getProducts() external view returns (Product[] memory) {
        return products;
    }

    function getProduct(uint256 product_id)
        external
        view
        returns (Product memory)
    {
        return products[product_id];
    }

    function getUser(address userAddress) external view returns (User memory) {
        return users[userAddress];
    }

    function withdrawBNB(address payable account) external onlyOwner {
        (bool success, ) = account.call{value: address(this).balance}("");
        require(success);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        require(token.transfer(to, amount));
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}
