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

const getStatusCodeFor = (name) => {
  switch(name) {
    case "PENDING":
      return 0;
    case "FAIL":
      return 1;
    case "ACCEPTED":
      return 2;
  }
  return -1;
}

module.exports = { toWei, fromWei, getBalance, getStatusCodeFor };