// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../owner/AdminRole.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SimpleToken is ERC20{
    uint8 private _decimals = 18;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 amount_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, amount_);
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

contract SHELL is ERC20Burnable, AdminRole {
    constructor() ERC20("koi SHELL", "SHELL") {}

    function mint(address recipient_, uint256 amount_)
        public
        onlyAdmin
        returns (bool)
    {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);
        return balanceAfter >= balanceBefore;
    }

    function burn(uint256 amount) public override onlyAdmin {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
        onlyAdmin
    {
        super.burnFrom(account, amount);
    }
}
