// SPDX-License-Identifier: MPL-2.0
// solhint-disable-next-line compiler-version
pragma solidity =0.8.24;

interface IWithdraw {
	function beforeBalanceChange(address _from, address _to) external;
}
