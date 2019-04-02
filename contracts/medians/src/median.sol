// median.sol - Medianizer v2

// Copyright (C) 2017, 2018  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.2;

contract Median {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "donut"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianETHUSD {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "ETHUSD"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianCOL1 {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "COL1"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianCOL2 {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "COL2"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianCOL3 {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "COL3"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianCOL4 {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "COL4"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianCOL5 {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "COL5"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}

contract MedianCOL6 {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128        val;
    uint32  public age;
    bytes32 public constant wat = "COL6"; // You want to change this every deploy
    uint256 public bar = 1;

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    // Whitelisted contracts, set by an auth
    mapping (address => bool) public bud;

    modifier toll { require(bud[msg.sender], "Contract is not whitelisted"); _;}
    
    event LogMedianPrice(uint256 val, uint256 age);

    //Set type of Oracle
    constructor() public {
        wards[msg.sender] = 1;
        age = uint32(block.timestamp);
    }

    function read() external view toll returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view toll returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == bar, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i]);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");
            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");
            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];
            // Bloom filter for signer uniqueness
            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
        }
        
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address[] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setBar(uint256 bar_) external auth {
        require(bar_ > 0, "Quorum has to be greater than 1");
        require(bar_ % 2 != 0, "Quorum has to be an odd number");
        bar = bar_;
    }

    function kiss(address a) external auth {
        require (a != address(0), "No contract 0");
        bud[a] = true;
    }

    function diss(address a) external auth {
        bud[a] = false;
    }
}
