// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MetaDappTokenSale {
    address public owner;
    uint256 private buyPrice;
    uint256 private sold;
    uint256 private toSold;
    address private noOne = address(0);
    IERC20 private token;
    uint256 private currentPhaseIndex;

    struct Phase {
        uint256 total;
        uint256 price;
        uint256 phase;
    }

    Phase[] private phases;

    event Sell(address _buyer, uint256 _amount);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        buyPrice = 0.000005 * 10**18;
        currentPhaseIndex = 0;
        sold = 0;
        toSold = __amount(250000);

        for (uint256 i = 1; i <= 10; i++) {
            phases.push(Phase(25000, buyPrice * i, i));
        }
    }

    function buy(uint256 tokens) public payable {
        require(
            msg.value / phase(currentPhaseIndex).price == tokens,
            "Fehler weil die Werte nicht uebereinstimmen"
        );
        require(
            phase(currentPhaseIndex).total <= __amount(tokens),
            "zu weniger Tokens"
        );
        require(
            token.balanceOf(address(this)) >= __amount(tokens),
            "zu wenig Tokens"
        );
        require(token.transfer(msg.sender, __amount(tokens)));

        sold += tokens;
        phases[currentPhaseIndex].total -= tokens;
        if (phase(currentPhaseIndex).total <= 0) currentPhaseIndex++;
        buyPrice = phase(currentPhaseIndex).price;

        emit Sell(msg.sender, tokens);
    }

    function __unAmount(uint256 _amount, uint256 decimals)
        private
        pure
        returns (uint256)
    {
        return _amount / (10**decimals);
    }

    function __tokens() public view returns (uint256) {
        return __unAmount(token.balanceOf(msg.sender), 18);
    }

    function __tokensPrice() public view returns (uint256) {
        return buyPrice;
    }

    function endSale() public isOwner {
        require(token.transfer(owner, token.balanceOf(address(this))));
        payable(owner).transfer(address(this).balance);
    }

    function tokenSold() public view returns (uint256) {
        return sold;
    }

    function totalTokens() public view returns (uint256) {
        return __unAmount(token.totalSupply(), 18);
    }

    function __phases() public view returns (Phase[] memory) {
        return phases;
    }

    function currentPhase() public view returns (Phase memory) {
        return phases[currentPhaseIndex];
    }

    function __isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function phase(uint256 phase_id) public view returns (Phase memory) {
        return phases[phase_id];
    }

    function __amount(uint256 _amount) private pure returns (uint256) {
        return _amount * (10**18);
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}
