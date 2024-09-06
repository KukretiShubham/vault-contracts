// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IWithdraw} from "./IWithdraw.sol";

contract MockToken is ERC20 {
	address public _withdraw;

	constructor(uint256 initialSupply, address withdraw) ERC20("Mock", "MOC") {
		_mint(msg.sender, initialSupply);
		_withdraw = withdraw;
	}

	function transfer(
		address _to,
		uint256 _value
	) public override returns (bool) {
		IWithdraw(_withdraw).beforeBalanceChange(msg.sender, _to);

		/**
		 * Calls the transfer of ERC20.
		 */
		_transfer(msg.sender, _to, _value);
		return true;
	}
}
