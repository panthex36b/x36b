// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin contracts via GitHub Raw (Remix-friendly)
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title IERC1643
 * @dev Interface for document management (ERC-1643).
 */
interface IERC1643 {
    event DocumentUpdated(bytes32 indexed name, string uri, bytes32 documentHash);
    event DocumentRemoved(bytes32 indexed name, bytes32 documentHash);

    function getDocument(bytes32 name) external view returns (string memory uri, bytes32 documentHash);
    function getAllDocuments() external view returns (bytes32[] memory);
    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;
    function removeDocument(bytes32 name) external;
}

/**
 * @title VersionedDocs
 * @dev Implements ERC-1643 with version history for documents.
 */
contract VersionedDocs is Ownable, IERC1643 {
    struct Document { string uri; bytes32 hash; }
    mapping(bytes32 => Document[]) private _history;
    bytes32[] private _names;

    /**
     * @dev Internal function to add a document version.
     */
    function _setDocument(
        bytes32 name,
        string memory uri,
        bytes32 documentHash
    ) internal {
        if (_history[name].length == 0) {
            _names.push(name);
        }
        _history[name].push(Document(uri, documentHash));
        emit DocumentUpdated(name, uri, documentHash);
    }

    function setDocument(
        bytes32 name,
        string calldata uri,
        bytes32 documentHash
    ) external override onlyOwner {
        _setDocument(name, uri, documentHash);
    }

    function removeDocument(bytes32 name) external override onlyOwner {
        require(_history[name].length > 0, "No such document");
        bytes32 oldHash = _history[name][_history[name].length - 1].hash;
        delete _history[name];
        emit DocumentRemoved(name, oldHash);
    }

    function getDocument(bytes32 name)
        external view override
        returns (string memory uri, bytes32 documentHash)
    {
        uint256 len = _history[name].length;
        require(len > 0, "No such document");
        Document storage doc = _history[name][len - 1];
        return (doc.uri, doc.hash);
    }

    function getAllDocuments() external view override returns (bytes32[] memory) {
        return _names;
    }

    function getDocumentVersion(
        bytes32 name,
        uint256 version
    ) external view returns (string memory uri, bytes32 documentHash) {
        require(version > 0 && version <= _history[name].length, "Invalid version");
        Document storage doc = _history[name][version - 1];
        return (doc.uri, doc.hash);
    }

    function getDocumentCount(bytes32 name) external view returns (uint256) {
        return _history[name].length;
    }
}

/**
 * @title Panthex36B
 * @dev ERC20 token with deflationary mechanics and versioned document registry.
 */
contract Panthex36B is ERC20, ERC20Burnable, VersionedDocs {
    // Fee parameters: 0.1%–0.2% (10–20 / 10_000)
    uint256 public feeRate;
    uint256 public constant FEE_DENOM = 10_000;

    // Annual burn parameters
    uint256 public lastAnnualBurn;
    uint256 public constant ANNUAL_RATE   = 500;      // 5% = 500/10_000
    uint256 public constant ANNUAL_PERIOD = 365 days;

    // Treasury and Reserve wallets
    address public treasuryWallet;
    address public reserveWallet;

    event FeesTaken(address indexed from, uint256 amount, uint256 burned, uint256 toTreasury, uint256 toReserve);
    event AnnualBurn(uint256 amount);

    /**
     * @notice Constructor with multi-document initial registration
     * @param institutions       address receiving 50% of total supply
     * @param exchanges          address receiving 30% of total supply
     * @param team               address receiving 10% of total supply (lock off-chain)
     * @param strategicReserve   address receiving 10% of total supply
     * @param _treasuryWallet    address receiving 40% of transaction fees
     * @param _reserveWallet     address receiving 10% of transaction fees
     * @param _feeRate           transaction fee in basis points (10–20 = 0.1–0.2%)
     * @param docNames           array of document names as strings
     * @param docUris            array of document URIs (IPFS/HTTPS)
     * @param docHashes          array of document content hashes (bytes32)
     */
    constructor(
        address institutions,
        address exchanges,
        address team,
        address strategicReserve,
        address _treasuryWallet,
        address _reserveWallet,
        uint256 _feeRate,
        string[] memory docNames,
        string[] memory docUris,
        bytes32[] memory docHashes
    ) ERC20("Panthex36B", "X36B") {
        require(_feeRate >= 10 && _feeRate <= 20, "Fee must be 0.1-0.2%");
        require(
            docNames.length == docUris.length &&
            docUris.length == docHashes.length,
            "Docs array mismatch"
        );

        feeRate        = _feeRate;
        treasuryWallet = _treasuryWallet;
        reserveWallet  = _reserveWallet;
        lastAnnualBurn = block.timestamp;

        uint256 total = 50_000_000_000 * 10**decimals();
        _mint(institutions,     total * 50 / 100);
        _mint(exchanges,        total * 30 / 100);
        _mint(team,             total * 10 / 100);
        _mint(strategicReserve, total * 10 / 100);

        // Register each initial document version (v1)
        for (uint256 i = 0; i < docNames.length; i++) {
            bytes32 nameHash = keccak256(abi.encodePacked(docNames[i]));
            _setDocument(nameHash, docUris[i], docHashes[i]);
        }
    }

    /** @dev Applies fee split 50/40/10 and burns 50% of the fee. */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (feeRate == 0 || from == address(0) || to == address(0)) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 fee        = (amount * feeRate) / FEE_DENOM;
        uint256 burnAmt    = (fee * 50) / 100;
        uint256 treasuryAmt = (fee * 40) / 100;
        uint256 reserveAmt = fee - burnAmt - treasuryAmt;
        uint256 netAmount  = amount - fee;

        _burn(from, burnAmt);
        super._transfer(from, treasuryWallet, treasuryAmt);
        super._transfer(from, reserveWallet,  reserveAmt);
        super._transfer(from, to, netAmount);

        emit FeesTaken(from, amount, burnAmt, treasuryAmt, reserveAmt);
    }

    /** @notice Burns 5% of total supply annually. */
    function annualBurn() external onlyOwner {
        require(block.timestamp >= lastAnnualBurn + ANNUAL_PERIOD, "Too early");
        uint256 amountToBurn = (totalSupply() * ANNUAL_RATE) / FEE_DENOM;
        _burn(owner(), amountToBurn);
        lastAnnualBurn = block.timestamp;
        emit AnnualBurn(amountToBurn);
    }

    // ——— Administrative setters ———
    function updateFeeRate(uint256 _feeRate) external onlyOwner {
        require(_feeRate >= 10 && _feeRate <= 20, "Fee 0.1-0.2%");
        feeRate = _feeRate;
    }

    function updateTreasuryWallet(address _treasury) external onlyOwner {
        treasuryWallet = _treasury;
    }

    function updateReserveWallet(address _reserve) external onlyOwner {
        reserveWallet = _reserve;
    }
}
