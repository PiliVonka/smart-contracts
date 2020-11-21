pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TadaamCoin is ERC20 {
	string public constant COIN_NAME = "TadaamCoin";
	string public constant COIN_SYMBOL = "TadaamCoin";
	uint8 public constant DECIMALS = 5;
	uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(DECIMALS));
	address[] public superUsers;	

	constructor (address[] memory sUsers) public ERC20(COIN_NAME, COIN_SYMBOL) 
    {
    	_mint(msg.sender, INITIAL_SUPPLY);
		_setupDecimals(DECIMALS);
		for (uint i = 0 ; i < sUsers.length ; ++i) {
			superUsers.push(sUsers[i]);
		}
	}
		
	modifier ifSuperUser {
		bool exists = false;
		for (uint i = 0 ; i < superUsers.length ; ++i) {
			if (msg.sender == superUsers[i]) {
				exists = true;
			}
		}
		require(exists);
		_;
	}	
	

	// Super User functions
	function receiveToken(address spender, uint256 amount) 
		ifSuperUser 
		public returns (bool) {
		_transfer(spender, msg.sender, amount);
		return true;
	}
}





