const ConvertLib = artifacts.require("ConvertLib");
const MetaCoin = artifacts.require("MetaCoin");
const TadaamCoin = artifacts.require("TadaamCoin");

module.exports = async (deployer) => {
  await deployer.deploy(ConvertLib);
  await deployer.link(ConvertLib, MetaCoin);
  await deployer.deploy(MetaCoin);
  await deployer.deploy(APIConsumer);  
  await deployer.deploy(TadaamCoin, []);
};
