// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint256) public s_balances;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    // string public name = "Manual Token";

    function toalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimal() public pure returns (uint256) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        // require(s_balances[msg.sender] >= _amount, "Insufficient balance.");
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalances, "Transfer failed.");
    }
}
