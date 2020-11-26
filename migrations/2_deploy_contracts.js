const RunCode = artifacts.require("RunCode");

module.exports = async (deployer) => {
  await deployer.deploy(RunCode, null);
};
