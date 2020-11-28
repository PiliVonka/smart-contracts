const RunCode = artifacts.require("RunCode");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(RunCode, accounts[0]);
};
