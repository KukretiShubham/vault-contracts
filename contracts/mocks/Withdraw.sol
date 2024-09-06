// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IWithdraw.sol";
import "../interfaces/ITransferHistory.sol";

abstract contract Withdraw is IWithdraw, ITransferHistory {
	mapping(address => mapping(uint256 => TransferHistory))
		internal _transferHistory;
	mapping(address => uint256) public transferHistoryLength;
	mapping(address => mapping(address => mapping(uint256 => uint256)))
		public transferHistoryOfSenderByIndex;
	mapping(address => mapping(address => mapping(uint256 => uint256)))
		public transferHistoryOfRecipientByIndex;
	mapping(address => mapping(address => uint256))
		public transferHistoryLengthOfSender;
	mapping(address => mapping(address => uint256))
		public transferHistoryLengthOfRecipient;

	function beforeBalanceChange(address _from, address _to) external override {
		IERC20 property = IERC20(msg.sender);

		updateTransferHistory(property, _from, _to);
	}

	function updateTransferHistory(
		IERC20 _property,
		address _from,
		address _to
	) internal {
		address prpty = address(_property);
		uint256 balanceOfSender = _property.balanceOf(_from);
		uint256 balanceOfRecipient = _property.balanceOf(_to);

		uint256 hId = transferHistoryLength[prpty];
		uint256 hSenderId = transferHistoryLengthOfSender[prpty][_from];
		uint256 hRecipientId = transferHistoryLengthOfRecipient[prpty][_to];

		transferHistoryLengthOfSender[prpty][_from] = hSenderId + 1;
		transferHistoryLengthOfRecipient[prpty][_to] = hRecipientId + 1;
		transferHistoryLength[prpty] = hId + 1;

		_transferHistory[prpty][hId] = TransferHistory(
			_to,
			_from,
			0,
			balanceOfRecipient,
			balanceOfSender,
			false,
			block.number
		);
		transferHistoryOfSenderByIndex[prpty][_from][hSenderId] = hId;
		transferHistoryOfRecipientByIndex[prpty][_to][hRecipientId] = hId;

		if (hId > 0) {
			// Update last TransferHistory if exists.
			TransferHistory storage lastHistory = _transferHistory[prpty][
				hId - 1
			];
			lastHistory.amount =
				lastHistory.preBalanceOfSender -
				_property.balanceOf(lastHistory.from);
			lastHistory.filled = true;
		}
	}

	function transferHistory(
		address _property,
		uint256 _index
	) external view returns (TransferHistory memory) {
		return _transferHistory[_property][_index];
	}
}
