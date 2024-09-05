// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ITransferHistory} from "./interfaces/ITransferHistory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClubsVault is Initializable {
	address public propertyAddress;
	address public withdAddress;
	uint256 public totalDeposits;

	// token => bool
	mapping(address => bool) public isAllowListed;
	// token => amount
	mapping(address => uint256) public totalReleasedTokens;
	// token => user => amount
	mapping(address => mapping(address => uint256)) public releasedTokensOfUser;
	// token => user => amount
	mapping(address => mapping(address => uint256)) public lastBalanceOfUser;

	// errors
	error InsufficientAllowance(uint256 required, uint256 available);
	event Deposited(uint256 amount);

	event Withdrawn(address token, address user, uint256 amount);

	function initialize(
		address _propertyAddress,
		address _withdrawAddress
	) external initializer {
		propertyAddress = _propertyAddress;
		withdAddress = _withdrawAddress;
	}

	function deposit(uint256 _amount, address _token) external {
		IERC20 token = IERC20(_token);
		if (token.allowance(msg.sender, address(this)) < _amount) {
			revert InsufficientAllowance(
				_amount,
				token.allowance(msg.sender, address(this))
			);
		}
		token.transferFrom(msg.sender, address(this), _amount);
		totalDeposits += _amount;
		emit Deposited(_amount);
	}

	// function calculateClaimableTokens(
	// 	address _user,
	// 	address _token
	// ) external view returns (uint256) {
	// 	IERC20 share = IERC20(propertyAddress);
	// 	uint256 userTokenBalance = share.balanceOf(_user);
	// 	uint256 totalTokenSupply = share.totalSupply();

	// 	// Calculate user's share of the treasury
	// 	uint256 userShare = (userTokenBalance * totalDeposits) /
	// 		totalTokenSupply;
	// 	uint256 userClaimed = releasedTokensOfUser[_token][_user];

	// 	// Return the remaining claimable balance
	// 	return userShare - userClaimed;
	// }
	function updateReleasedTokens(
		address _token,
		address _user,
		uint256 _currentPropertyBalance
	) private {
		IERC20 property = IERC20(propertyAddress);
		if (lastBalanceOfUser[_token][_user] >= _currentPropertyBalance) {
			// If the current user balance is smaller or equal to the last balance, no need to update `releasedTokensOfUser`.
			// Because in that case, the value of `releasedTokensOfUser` is always greater than the withdrawable amount, so no double payment occurs.
			return;
		}

		// historyLength is similar to Array.length and matches the number of values ​​it has.
		uint256 historyLength = ITransferHistory(withdAddress)
			.transferHistoryLength(propertyAddress);
		uint256 count = 0;
		uint256 i = historyLength > 0 ? historyLength - 1 : 0;

		while (historyLength - count > 0) {
			ITransferHistory.TransferHistory memory history = ITransferHistory(
				withdAddress
			).transferHistory(
					propertyAddress,
					ITransferHistory(withdAddress)
						.transferHistoryOfRecipientByIndex(
							propertyAddress,
							_user,
							i
						)
				);
			if (!history.filled) {
				history.amount =
					_currentPropertyBalance -
					history.preBalanceOfRecipient;
			}
			updateReleasedTokens(
				_token,
				history.from,
				property.balanceOf(history.from)
			);

			uint256 releasedTokens = releasedTokensOfUser[_token][history.from];
			uint256 partOfReleasedTokens = (releasedTokens *
				history.preBalanceOfSender) / history.amount;

			releasedTokensOfUser[_token][_user] =
				partOfReleasedTokens +
				releasedTokensOfUser[_token][_user];

			i = i > 0 ? i - 1 : i;

			count++;
		}
	}

	function withdraw(address _token, address _user) external {
		IERC20 property = IERC20(propertyAddress);
		IERC20 token = IERC20(_token);

		uint256 totalReceivedTokens = token.balanceOf(address(this)) +
			totalReleasedTokens[_token];

		uint256 userBalance = property.balanceOf(_user);

		updateReleasedTokens(_token, _user, userBalance);

		uint256 released = releasedTokensOfUser[_token][_user];
		uint256 propertyTotalSupply = property.totalSupply();

		uint256 total = (totalReceivedTokens * userBalance) /
			propertyTotalSupply;
		uint256 payment = total > released ? total - released : 0;

		// Update global state
		releasedTokensOfUser[_token][_user] = released + payment;
		totalReleasedTokens[_token] += payment;
		lastBalanceOfUser[_token][_user] = userBalance;

		// Transfer the tokens to the user
		token.transfer(_user, payment);
		emit Withdrawn(_token, _user, payment);
	}
}
