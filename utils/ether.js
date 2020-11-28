const toWei = (value) => {
  return web3.utils.toWei(
    typeof(value) === "string" ? value : value.toString(), "ether"
  );
}

const fromWei = (value) => {
  return web3.utils.fromWei(
    typeof(value) === "string" ? value : value.toString(), "ether"
  );
}

const getBalance = (address) => {
  return web3.eth.getBalance(address);
}

module.exports = { toWei, fromWei, getBalance };