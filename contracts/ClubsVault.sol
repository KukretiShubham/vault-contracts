// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ClubsVault is Initializable {
	address public propertyAddress;
	uint256 public totalDeposits;


	// token => bool
	mapping( address => bool) public isAllowListed;
	// token => amount
	mapping (address => uint256) public totalReleasedTokens;
	// token => user => amount
	mapping (address => mapping(address => uint256)) public releasedTokensOfUser;
	
	// errors
	error InsufficientAllowance(uint256 required, uint256 available);
	event Deposited(
		uint256 amount
	);

	event Withdrawn(
		uint256 amount
	);

	function initialize(address _propertyAddress) external initializer {
		propertyAddress = _propertyAddress;
	}

	function deposit(uint256 _amount, address _token) external {
		IERC20 token = IERC20(_token);
		if (token.allowance(msg.sender, address(this)) < _amount) {
			revert InsufficientAllowance(_amount, token.allowance(msg.sender, address(this)));
		}
		token.transferFrom(msg.sender, address(this), _amount);
		totalDeposits += _amount;
		emit Deposited(_amount);
	}

	function calculateClaimableTokens(address _user, address _token) external view returns (uint256) {
		IERC20 share = IERC20(propertyAddress);
		uint256 userTokenBalance = share.balanceOf(_user);
        uint256 totalTokenSupply = share.totalSupply();

        // Calculate user's share of the treasury
        uint256 userShare = (userTokenBalance * totalDeposits) / totalTokenSupply;
        uint256 userClaimed = releasedTokensOfUser[_token][_user];

        // Return the remaining claimable balance
        return userShare - userClaimed;
	}
	function updateReleasedTokens (address _token, address _user, uint256 _currentPropertyBalance) private {

	}

	function withdraw(address _token, address _user) external {
		IERC20 property = IERC20(propertyAddress);
		IERC20 token = IERC20(_token);

		uint256 totalReceivedTokens = token.balanceOf(address(this)) + totalReleasedTokens[_token];
		
		uint256 userBalance = property.balanceOf(_user);

		updateReleasedTokens(_token, _user, userBalance);

		uint256 released = releasedTokensOfUser[_token][_user];
		uint propertyTotalSupply = property.totalSupply();

		uint256 payment = (totalReceivedTokens * userBalance) / propertyTotalSupply - released;


		emit Withdrawn();
	}

}
