const MetaDappTokenSale = artifacts.require("MetaDappTokenSale");

module.exports = function (deployer) {
  deployer.deploy(MetaDappTokenSale, "0x14147b166E28881BD15F5f088E87573EE6C83b75");
};
