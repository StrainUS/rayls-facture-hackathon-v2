// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RLSToken
 * @author Karim Y (StrainUS) — github.com/StrainUS
 * @notice RLS — Rayls Liquidity Staking Token
 * @dev ERC-20 avec tokenomics déflationnistes :
 *      - Supply totale : 368 000 RLS
 *      - Burn automatique de 0.5% à chaque transfert normal
 *      - Minting réservé au owner
 */
contract RLSToken is ERC20, ERC20Burnable, Ownable {
    /// @notice Supply maximale : 368 000 RLS (18 decimals)
    uint256 public constant MAX_SUPPLY = 368_000 * 10 ** 18;

    /// @notice Taux de burn en basis points : 50 = 0.5%
    uint256 public constant BURN_BPS = 50;

    /// @notice Total brûlé depuis le déploiement
    uint256 public totalBurned;

    // =========================================================
    // EVENTS
    // =========================================================

    event TokensBurned(address indexed from, uint256 amount);
    event BatchMinted(address[] recipients, uint256[] amounts, uint256 totalMinted);

    // =========================================================
    // ERRORS
    // =========================================================

    error ExceedsMaxSupply(uint256 requested, uint256 available);
    error ArrayLengthMismatch();
    error ZeroAmount();
    error ZeroAddress();

    // =========================================================
    // CONSTRUCTOR
    // =========================================================

    /**
     * @notice Déploie le token RLS et mint la moitié de la supply au owner
     * @param initialMint Montant initial à minter (max MAX_SUPPLY)
     */
    constructor(uint256 initialMint) ERC20("Rayls Liquidity Staking", "RLS") Ownable(msg.sender) {
        if (initialMint > MAX_SUPPLY) revert ExceedsMaxSupply(initialMint, MAX_SUPPLY);
        if (initialMint > 0) {
            _mint(msg.sender, initialMint);
        }
    }

    // =========================================================
    // MINT
    // =========================================================

    /**
     * @notice Mint des tokens RLS (owner uniquement)
     * @param to     Destinataire
     * @param amount Montant en wei
     */
    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        uint256 available = MAX_SUPPLY - totalSupply();
        if (amount > available) revert ExceedsMaxSupply(amount, available);
        _mint(to, amount);
    }

    /**
     * @notice Mint en batch pour distribuer à plusieurs adresses
     * @param recipients Tableau de destinataires
     * @param amounts    Tableau de montants correspondants
     */
    function batchMint(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        uint256 len = recipients.length;
        if (len != amounts.length) revert ArrayLengthMismatch();

        uint256 total;
        unchecked {
            for (uint256 i; i < len; ++i) {
                total += amounts[i];
            }
        }

        uint256 available = MAX_SUPPLY - totalSupply();
        if (total > available) revert ExceedsMaxSupply(total, available);

        unchecked {
            for (uint256 i; i < len; ++i) {
                if (recipients[i] == address(0)) revert ZeroAddress();
                _mint(recipients[i], amounts[i]);
            }
        }

        emit BatchMinted(recipients, amounts, total);
    }

    // =========================================================
    // DEFLATIONARY TRANSFER HOOK
    // =========================================================

    /**
     * @notice Override interne : applique 0.5% de burn sur chaque transfert normal
     * @dev Mint (from == 0) et burn (to == 0) sont exemptés
     */
    function _update(address from, address to, uint256 amount) internal override {
        // Exemption : mint et burn directs
        if (from == address(0) || to == address(0)) {
            super._update(from, to, amount);
            return;
        }

        // Calcul du burn : 0.5% de amount
        uint256 burnAmount = (amount * BURN_BPS) / 10_000;
        uint256 transferAmount = amount - burnAmount;

        // Burn d'abord
        if (burnAmount > 0) {
            super._update(from, address(0), burnAmount);
            unchecked { totalBurned += burnAmount; }
            emit TokensBurned(from, burnAmount);
        }

        // Transfert du reste
        super._update(from, to, transferAmount);
    }

    // =========================================================
    // VIEW
    // =========================================================

    /// @notice Supply encore mintable avant d'atteindre le maximum
    function remainingMintable() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    /// @notice Simulation du montant net reçu après burn pour un transfert
    function netAmount(uint256 amount) external pure returns (uint256 received, uint256 burned) {
        burned = (amount * BURN_BPS) / 10_000;
        received = amount - burned;
    }
}
